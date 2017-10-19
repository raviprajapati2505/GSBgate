class AddScreenedToSchemeMixCriteria < ActiveRecord::Migration
  def change
    add_column :scheme_mix_criteria, :screened, :boolean, null: false, default: false
  end
end
