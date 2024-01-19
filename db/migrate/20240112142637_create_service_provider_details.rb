class CreateServiceProviderDetails < ActiveRecord::Migration[7.0]
  def change
    create_table :service_provider_details do |t|
      t.references :service_provider, foreign_key: {to_table: :users}
      t.string :business_field
      t.string :portfolio
      t.string :commercial_licence_no
      t.string :commercial_licence_file
      t.date :commercial_licence_expiry_date
      t.string :accredited_service_provider_licence_file
      t.string :demerit_acknowledgement_file
      t.string :application_form
      t.string :cgp_licence_file
      t.string :gsb_energey_assessment_licence_file
      t.string :energy_assessor_name
      t.string :nominated_cgp
      t.string :exam
      t.string :workshop

      t.timestamps
    end
  end
end
