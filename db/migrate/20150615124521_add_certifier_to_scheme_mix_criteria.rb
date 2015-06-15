class AddCertifierToSchemeMixCriteria < ActiveRecord::Migration
  def change
    add_reference :scheme_mix_criteria, :certifier, references: :users, index: true
  end
end
