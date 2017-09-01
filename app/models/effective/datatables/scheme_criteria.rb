module Effective
  module Datatables
    class SchemeCriteria < Effective::Datatable
      include ActionView::Helpers::TranslationHelper

      attr_accessor :current_ability

      datatable do
        table_column 'scheme_category_name', column: 'scheme_categories.name', :filter => {:type => :select, :values => Proc.new{SchemeCategory.unscope(:order).order(:name).distinct.pluck(:name)}} do |rec|
          link_to(rec.scheme_category_name, scheme_category_path(rec.scheme_category_id))
        end
        table_column 'scheme_category_code', column: 'scheme_categories.code', :filter => {:type => :select, :values => Proc.new{SchemeCategory.unscope(:order).order(:code).distinct.pluck(:code)}}
        table_column 'scheme_criterion_number', column: 'scheme_criteria.number'
        table_column 'scheme_criterion_name', column: 'scheme_criteria.name', :filter => {:type => :select, :values => Proc.new{SchemeCriterion.order(:name).distinct.pluck(:name)}} do |rec|
          link_to(rec.scheme_criterion_name, scheme_criterion_path(rec.scheme_criterion_id))
        end
        table_column 'scheme_name', column: 'schemes.name', :filter => {:type => :select, :values => Proc.new{Scheme.order(:name).distinct.pluck(:name)}} do |rec|
          link_to(rec.scheme_name, scheme_path(rec.scheme_id))
        end
        table_column 'scheme_gsas_version', column: 'schemes.gsas_version', :filter => {:type => :select, :values => Proc.new{Scheme.order(:gsas_version).distinct.pluck(:gsas_version)}}
        table_column 'scheme_renovation', column: 'schemes.renovation', type: :boolean
        table_column 'scheme_gsas_document', column: 'schemes.gsas_document', :filter => {:type => :select, :values => Proc.new{Scheme.order(:gsas_document).distinct.pluck(:gsas_document)}}
        table_column 'development_type_name', column: 'development_types.name', :filter => {:type => :select, :values => Proc.new{DevelopmentType.order(:name).distinct.pluck(:name)}}
        table_column 'certificate_name', column: 'certificates.name', :filter => {:type => :select, :values => Proc.new{Certificate.order(:name).distinct.pluck(:name)}}
        table_column 'certificate_gsas_version', column: 'certificates.gsas_version', :filter => {:type => :select, :values => Proc.new{Certificate.order(:gsas_version).distinct.pluck(:gsas_version)}}
      end

      def collection
        coll = SchemeCriterion
                   .joins('LEFT JOIN scheme_categories ON scheme_criteria.scheme_category_id = scheme_categories.id')
                   .joins('LEFT JOIN schemes ON scheme_categories.scheme_id = schemes.id')
                   .joins('LEFT JOIN development_type_schemes ON development_type_schemes.scheme_id = schemes.id')
                   .joins('LEFT JOIN development_types ON development_types.id = development_type_schemes.development_type_id')
                   .joins('LEFT JOIN certificates ON certificates.id = development_types.certificate_id')
                   .select('schemes.gsas_version as scheme_gsas_version')
                   .select('schemes.gsas_document as scheme_gsas_document')
                   .select('schemes.renovation as scheme_renovation')
                   .select('scheme_categories.id as scheme_category_id')
                   .select('scheme_categories.code as scheme_category_code')
                   .select('scheme_categories.name as scheme_category_name')
                   .select('scheme_criteria.id as scheme_criterion_id')
                   .select('scheme_criteria.name as scheme_criterion_name')
                   .select('scheme_criteria.number as scheme_criterion_number')
                   .select('schemes.name as scheme_name')
                   .select('schemes.id as scheme_id')
                   .select('development_types.name as development_type_name')
                   .select('certificates.name as certificate_name')
                   .select('certificates.gsas_version as certificate_gsas_version')
        # Ensure we always have an ability, so we will not show unauthorized data
        if current_ability.nil?
          # Rails.logger.debug "NO ABILITY"
          return coll.none
        else
          # use cancan ability to limit the authorized certifier criteria
          # Rails.logger.debug "ABILITY OK"
          return coll.accessible_by(current_ability)
        end
      end

    end
  end
end