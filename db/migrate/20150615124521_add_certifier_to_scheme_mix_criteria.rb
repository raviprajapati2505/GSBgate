class AddCertifierToSchemeMixCriteria < ActiveRecord::Migration[4.2]
  def change
    add_reference :scheme_mix_criteria, :certifier, references: :users, index: true
  end
end
