class AddLabelToRequirement < ActiveRecord::Migration
  def change
    add_column :requirements, :label, :string
  end
end
