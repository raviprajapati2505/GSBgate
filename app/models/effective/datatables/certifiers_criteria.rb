module Effective
  module Datatables
    class CertifiersCriteria < Effective::Datatable
      include ActionView::Helpers::TranslationHelper

      datatable do
        col :certifier_name, sql_column: 'certifiers.name'
        col :certifier_email, sql_column: 'certifiers.email'

        col :scheme_mix_criteria_due_date, sql_column: 'scheme_mix_criteria.due_date', label: 'Due Date', as: :date, search: { as: :select, collection: Proc.new { SchemeMixCriterion.pluck_date_field_by_year_month_day(:due_date, :desc) } } do |rec|
          localize(rec.scheme_mix_criteria_due_date.in_time_zone, format: :date_only) unless rec.scheme_mix_criteria_due_date.nil?
        end

        col :scheme_criterion_name, sql_column: 'scheme_criteria.name'

        col :scheme_category_name, sql_column: 'scheme_categories.name'
        # col :scheme_category_code, sql_column: 'scheme_categories.code'
        # col :scheme_criterion_number, sql_column: 'scheme_criteria.number'

        # col :project_code, sql_column: 'projects.code' do |rec|
        #   link_to(project_path(rec.project_id)) do
        #     rec.project_code
        #   end
        # end
        col :project_name, sql_column: 'projects.name' do |rec|
          link_to(project_path(rec.project_id)) do
            rec.project_name
          end
        end
        # col :project_created_at, sql_column: 'projects.created_at', as: :datetime, search: {as: :select, collection: Proc.new { Project.pluck_date_field_by_year_month_day(:created_at, :desc) }} do |rec|
        #   localize(rec.project_created_at.in_time_zone) unless rec.project_created_at.nil?
        # end

        col :certificate_id, sql_column: 'certificates.id', label: t('models.effective.datatables.certifiers_criteria.certificate_id.label'), search: { as: :select, collection: Proc.new { Certificate.all.order(:display_weight).map { |certificate| [certificate.full_name, certificate.id] } } } do |rec|
          if rec.certification_path_id.present?
            link_to(project_certification_path_path(rec.project_id, rec.certification_path_id)) do
              rec.certificate_name
            end
          end
        end

        # col :certification_path_certification_path_status_id, sql_column: 'certification_paths.certification_path_status_id', label: t('models.effective.datatables.certifiers_criteria.certification_path_certification_path_status_id.label'), search: {as: :select, collection: Proc.new { CertificationPathStatus.all.map { |status| [status.name, status.id] } }} do |rec|
        #   rec.certification_path_status_name
        # end
        # col :certification_path_status_is_active', sql_column: 'CASE WHEN certification_path_statuses.id IS NULL THEN false WHEN certification_path_statuses.id = 15 THEN false WHEN certification_path_statuses.id = 16 THEN false ELSE true END', as: :boolean, label: t('models.effective.datatables.projects_certification_paths.certification_path_status_is_active.label')

        col :schemes_name, sql_column: 'schemes.name' do |rec|
          if rec.scheme_mix_id.present?
            link_to(project_certification_path_scheme_mix_path(rec.project_id, rec.certification_path_id, rec.scheme_mix_id)) do
              rec.scheme_name
            end
          end
        end

        # col :scheme_mix_criteria_status, sql_column: 'scheme_mix_criteria.status', as: :integer, label: t('models.effective.datatables.certifiers_criteria.scheme_mix_criteria_status.label'), search: {as: :select, collection: Proc.new { SchemeMixCriterion.statuses.map { |k| [t(k[0], scope: 'activerecord.attributes.scheme_mix_criterion.statuses'), k[1]] } }} do |rec|
        #   t(SchemeMixCriterion.statuses.key(rec.scheme_mix_criteria_status), scope: 'activerecord.attributes.scheme_mix_criterion.statuses') unless rec.scheme_mix_criteria_status.nil?
        # end
      end

      collection do
        Project
          .joins('LEFT OUTER JOIN certification_paths ON certification_paths.project_id = projects.id')
          .joins('LEFT JOIN certification_path_statuses ON certification_path_statuses.id = certification_paths.certification_path_status_id')
          .joins('LEFT JOIN certificates ON certificates.id = certification_paths.certificate_id')
          .joins('LEFT JOIN scheme_mixes ON scheme_mixes.certification_path_id = certification_paths.id')
          .joins('LEFT JOIN schemes ON schemes.id = scheme_mixes.scheme_id')
          .joins('LEFT JOIN scheme_mix_criteria ON scheme_mix_criteria.scheme_mix_id = scheme_mixes.id')
          .joins('LEFT JOIN scheme_criteria ON scheme_criteria.id = scheme_mix_criteria.scheme_criterion_id')
          .joins('LEFT JOIN scheme_categories ON scheme_categories.id = scheme_criteria.scheme_category_id')
          .joins('LEFT JOIN users as certifiers ON certifiers.id = scheme_mix_criteria.certifier_id')
          .select('projects.id as project_id')
          .select('projects.code as project_code')
          .select('projects.name as project_name')
          .select('projects.created_at as project_created_at')
          .select('certification_paths.id as certification_path_id')
          .select('certification_paths.certificate_id as certificate_id')
          .select('certification_paths.certification_path_status_id as certification_path_certification_path_status_id')
          .select("certificates.name as certificate_name")
          .select('certification_path_statuses.name as certification_path_status_name')
          .select('CASE WHEN certification_path_statuses.id IS NULL THEN false WHEN certification_path_statuses.id = 15 THEN false WHEN certification_path_statuses.id = 16 THEN false WHEN certification_path_statuses.id = 17 THEN false ELSE true END as certification_path_status_is_active')
          .select('scheme_mixes.id as scheme_mix_id')
          .select('schemes.name as scheme_name')
          .select('scheme_mix_criteria.id as scheme_mix_criteria_id')
          .select('scheme_mix_criteria.status as scheme_mix_criteria_status')
          .select('scheme_mix_criteria.due_date as scheme_mix_criteria_due_date')
          .select('scheme_criteria.id as scheme_criterion_id')
          .select('scheme_criteria.name as scheme_criterion_name')
          .select('scheme_criteria.number as scheme_criterion_number')
          .select('scheme_categories.id as scheme_category_id')
          .select('scheme_categories.code as scheme_category_code')
          .select('scheme_categories.name as scheme_category_name')
          .select('certifiers.id as certifier_id')
          .select('certifiers.email as certifier_email')
          .select('certifiers.name as certifier_name')
          .where("certification_paths.certification_path_status_id IN (#{CertificationPathStatus::VERIFYING}, #{CertificationPathStatus::VERIFYING_AFTER_APPEAL})")
          .where("scheme_mix_criteria.status IN (#{SchemeMixCriterion.statuses[:verifying]}, #{SchemeMixCriterion.statuses[:verifying_after_appeal]})")
          .accessible_by(current_ability)
      end

    end
  end
end