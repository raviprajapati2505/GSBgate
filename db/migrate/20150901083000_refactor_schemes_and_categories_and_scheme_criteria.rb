class RefactorSchemesAndCategoriesAndSchemeCriteria < ActiveRecord::Migration
  def change
    #renaming label to name
    rename_column :certificates, :label, :name
    rename_column :requirements, :label, :name
    rename_column :schemes, :label, :name
    rename_column :fields, :name, :machine_name
    rename_column :fields, :label, :name

    # remove categories and criterias, as these were scheme independent
    remove_foreign_key :criteria, :categories
    drop_table :categories

    remove_foreign_key :scheme_criteria, :criteria
    drop_table :criteria

    # add index to schemes, to improve lookup
    add_index :schemes, [:name, :version, :certificate_id], unique: true

    # create scheme dependent categories
    create_table :scheme_categories do |t|
      t.string :name
      t.string :code, limit: 2
      t.text :description
      t.text :impacts
      t.text :mitigate_impact
      t.references :scheme, index: true, foreign_key: true
      t.timestamps null: false
    end
    add_index :scheme_categories, [:code, :scheme_id], unique: true

    # alter scheme_mix_criteria
    remove_column :scheme_mix_criteria, :targeted_score_a
    remove_column :scheme_mix_criteria, :targeted_score_b
    remove_column :scheme_mix_criteria, :submitted_score_a
    remove_column :scheme_mix_criteria, :submitted_score_b
    remove_column :scheme_mix_criteria, :achieved_score_a
    remove_column :scheme_mix_criteria, :achieved_score_b
    add_column :scheme_mix_criteria, :targeted_score, :integer
    add_column :scheme_mix_criteria, :submitted_score, :integer
    add_column :scheme_mix_criteria, :achieved_score, :integer

    # alter scheme_criteria
    remove_column :scheme_criteria, :scheme_id
    remove_column :scheme_criteria, :criterion_id
    remove_column :scheme_criteria, :code
    remove_column :scheme_criteria, :score_a
    remove_column :scheme_criteria, :score_b
    remove_column :scheme_criteria, :score_description
    remove_column :scheme_criteria, :score_combination_type
    add_column :scheme_criteria, :name, :string
    add_column :scheme_criteria, :number, :integer
    add_column :scheme_criteria, :scores, :string
    add_reference :scheme_criteria, :scheme_category, index: true, foreign_key: true
    add_index :scheme_criteria, [:scheme_category_id, :number], unique: true
    add_index :scheme_criteria, [:scheme_category_id, :name], unique: true

    # create scheme_criterion_texts
    create_table :scheme_criterion_texts do |t|
      t.string :name
      t.text :html_text
      t.integer :display_weight
      t.boolean :visible
      t.references :scheme_criterion, index: true, foreign_key: true
      t.timestamps null: false
    end
    add_index :scheme_criterion_texts, [:name, :scheme_criterion_id], unique: true
  end
end
