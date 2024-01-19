module Effective
  module Datatables
    class SchemeCriteria < Effective::Datatable
      include ActionView::Helpers::TranslationHelper

      datatable do
        col :scheme_category_name, sql_column: 'scheme_categories.name', search: { as: :select, collection: Proc.new { SchemeCategory.unscope(:order).order(:name).distinct.pluck(:name) } } do |rec|
          link_to(rec.scheme_category_name, scheme_category_path(rec.scheme_category_id))
        end
        col :scheme_category_code, sql_column: 'scheme_categories.code', search: { as: :select, collection: Proc.new { SchemeCategory.unscope(:order).order(:code).distinct.pluck(:code) } }
        col :scheme_criterion_number, sql_column: 'scheme_criteria.number', as: :integer, search: { as: :select, collection: Proc.new { SchemeCriterion.unscope(:order).order(:number).distinct.pluck(:number) } }
        col :scheme_criterion_name, sql_column: 'scheme_criteria.name', search: { as: :select, collection: Proc.new { SchemeCriterion.order(:name).distinct.pluck(:name) } } do |rec|
          link_to(rec.scheme_criterion_name, scheme_criterion_path(rec.scheme_criterion_id))
        end
        col :scheme_name, sql_column: 'schemes.name', search: { as: :select, collection: Proc.new { Scheme.order(:name).distinct.pluck(:name) } } do |rec|
          link_to(rec.scheme_name, scheme_path(rec.scheme_id))
        end
        col :scheme_gsb_version, visible: false, sql_column: 'schemes.gsb_version', search: { as: :select, collection: Proc.new { Scheme.order(:gsb_version).distinct.pluck(:gsb_version) } }
        col :scheme_renovation, visible: false, sql_column: 'schemes.renovation', as: :boolean
        col :scheme_gsb_document, visible: false, sql_column: 'schemes.gsb_document', search: { as: :select, collection: Proc.new { Scheme.order(:gsb_document).distinct.pluck(:gsb_document) } }
        col :development_types_array, label: "Development Types", sql_column: "ARRAY_TO_STRING(ARRAY(SELECT distinct development_types.name FROM development_types INNER JOIN development_type_schemes ON development_type_schemes.development_type_id = development_types.id WHERE development_type_schemes.scheme_id = schemes.id), '|||')", search: { as: :select, collection: Proc.new { DevelopmentType.unscope(:order).distinct.pluck(:name) } } do |rec|
          ERB::Util::html_escape(rec.development_types_array).split('|||').sort.join('<br/>') unless rec.development_types_array.nil?
        end
        col :certificates_array, label: "Certificates", sql_column: "ARRAY_TO_STRING(ARRAY(SELECT distinct certificates.name FROM certificates INNER JOIN development_types ON development_types.certificate_id = certificates.id INNER JOIN development_type_schemes ON development_type_schemes.development_type_id = development_types.id WHERE development_type_schemes.scheme_id = schemes.id), '|||')", search: { as: :select, collection: Proc.new { Certificate.unscope(:order).distinct.pluck(:name) } } do |rec|
          ERB::Util::html_escape(rec.certificates_array).split('|||').sort.join('<br/>') unless rec.certificates_array.nil?
        end
        col :certificates_gsb_version, sql_column: "(SELECT distinct certificates.gsb_version FROM certificates INNER JOIN development_types ON development_types.certificate_id = certificates.id INNER JOIN development_type_schemes ON development_type_schemes.development_type_id = development_types.id WHERE development_type_schemes.scheme_id = schemes.id)", search: { as: :select, collection: Proc.new { Certificate.unscope(:order).order(:gsb_version).distinct.pluck(:gsb_version) } } do |rec|
          ERB::Util::html_escape(rec.certificates_gsb_version).split('|||').sort.join('<br/>') unless rec.certificates_gsb_version.nil?
        end
      end

      collection do
        SchemeCriterion
          .joins('LEFT JOIN scheme_categories ON scheme_criteria.scheme_category_id = scheme_categories.id')
          .joins('LEFT JOIN schemes ON scheme_categories.scheme_id = schemes.id')
          .select('schemes.gsb_version as scheme_gsb_version')
          .select('schemes.gsb_document as scheme_gsb_document')
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
          .select("(SELECT distinct certificates.gsb_version FROM certificates INNER JOIN development_types ON development_types.certificate_id = certificates.id INNER JOIN development_type_schemes ON development_type_schemes.development_type_id = development_types.id WHERE development_type_schemes.scheme_id = schemes.id) AS certificates_gsb_version")
          .accessible_by(current_ability)
      end
    end
  end
end