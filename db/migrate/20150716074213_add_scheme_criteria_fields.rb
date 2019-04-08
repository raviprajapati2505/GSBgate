class AddSchemeCriteriaFields < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_criteria, :score_description, :text
    add_column :scheme_criteria, :score_class_name, :string
    add_column :scheme_criteria, :score_type_a, :string
    add_column :scheme_criteria, :score_type_b, :string
  end
end
