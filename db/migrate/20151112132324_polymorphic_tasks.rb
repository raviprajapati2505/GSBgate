class PolymorphicTasks < ActiveRecord::Migration
  def change
    remove_column :tasks, :type, :string
    remove_column :tasks, :project_id, :integer
    remove_column :tasks, :certification_path_id, :integer
    remove_column :tasks, :scheme_mix_criterion_id, :integer
    remove_column :tasks, :requirement_datum_id, :integer
    remove_column :tasks, :scheme_mix_criteria_document_id, :integer
    add_reference :tasks, :taskable, polymorphic: :true, index: true
    add_reference :tasks, :project, index: true, foreign_key: true
    add_reference :tasks, :certification_path, index: true, foreign_key: true
  end
end
