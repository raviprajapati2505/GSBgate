class AddEpcMatchesEnergySuite < ActiveRecord::Migration[5.2]
  def change
    add_column :scheme_mix_criteria, :epc_matches_energy_suite, :boolean
    add_column :scheme_mix_criteria_documents, :document_type, :integer, default: 0
  end
end
