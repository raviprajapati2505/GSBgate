class AddMissingRelationships < ActiveRecord::Migration
  def change
    add_foreign_key(:certification_paths, :certificates)
    add_foreign_key(:requirement_data, :requirements)
    add_foreign_key(:scores, :scheme_criteria)
    add_foreign_key(:field_data, :calculator_data)
  end
end
