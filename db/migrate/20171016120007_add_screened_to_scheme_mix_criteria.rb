class AddScreenedToSchemeMixCriteria < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_mix_criteria, :screened, :boolean, null: false, default: false
  end
end
