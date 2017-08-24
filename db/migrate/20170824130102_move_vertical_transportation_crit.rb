class MoveVerticalTransportationCrit < ActiveRecord::Migration
  def change
    scheme_category = SchemeCategory.select(:id).joins(:scheme).where(code: 'MO', schemes: {gsas_version: '2.0', name: 'Healthcare'}).first
    SchemeCriterion.joins(scheme_category: [:scheme]).where(name: 'Vertical Transportation', scheme_categories: {code: 'E'}, schemes: {gsas_version: '2.0'}).update_all(number: 10, scheme_category_id: scheme_category.id)
  end
end
