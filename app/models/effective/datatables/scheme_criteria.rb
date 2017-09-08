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
        table_column 'scheme_gsas_document', visible: false, column: 'schemes.gsas_document', :filter => {:type => :select, :values => Proc.new{Scheme.order(:gsas_document).distinct.pluck(:gsas_document)}}
        table_column 'development_types_array', label: "Development Types", column: "ARRAY_TO_STRING(ARRAY(SELECT distinct development_types.name FROM development_types INNER JOIN development_type_schemes ON development_type_schemes.development_type_id = development_types.id WHERE development_type_schemes.scheme_id = schemes.id), '|||') AS development_types_array" do |rec|
          ERB::Util::html_escape(rec.development_types_array).split('|||').sort.join('<br/>') unless rec.development_types_array.nil?
        end
        table_column 'certificates_array', label: "Certificates", column: "ARRAY_TO_STRING(ARRAY(SELECT distinct certificates.name FROM certificates INNER JOIN development_types ON development_types.certificate_id = certificates.id INNER JOIN development_type_schemes ON development_type_schemes.development_type_id = development_types.id WHERE development_type_schemes.scheme_id = schemes.id), '|||') AS certificates_array" do |rec|
          ERB::Util::html_escape(rec.certificates_array).split('|||').sort.join('<br/>') unless rec.certificates_array.nil?
        end
      end

      def collection
        coll = SchemeCriterion
                   .joins('LEFT JOIN scheme_categories ON scheme_criteria.scheme_category_id = scheme_categories.id')
                   .joins('LEFT JOIN schemes ON scheme_categories.scheme_id = schemes.id')
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
                   .select("ARRAY_TO_STRING(ARRAY(SELECT distinct development_types.name FROM development_types INNER JOIN development_type_schemes ON development_type_schemes.development_type_id = development_types.id WHERE development_type_schemes.scheme_id = schemes.id), '|||') AS development_types_array")
                   .select("ARRAY_TO_STRING(ARRAY(SELECT distinct certificates.name FROM certificates INNER JOIN development_types ON development_types.certificate_id = certificates.id INNER JOIN development_type_schemes ON development_type_schemes.development_type_id = development_types.id WHERE development_type_schemes.scheme_id = schemes.id), '|||') AS certificates_array")
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