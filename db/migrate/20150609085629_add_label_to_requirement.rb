class AddLabelToRequirement < ActiveRecord::Migration[4.2]
  def change
    add_column :requirements, :label, :string
  end
end
