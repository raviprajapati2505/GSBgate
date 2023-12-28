class AddSharedColumnToSchemeCategory < ActiveRecord::Migration[4.2]
  def up
    add_column :scheme_categories, :shared, :boolean, default: false, null: false
    # update the shared categories, but only those within the design type certificates (i.e. LOC and FinalDesign)
    SchemeCategory
        .joins(scheme: :certificate)
        .where(certificates: {certificate_type: Certificate.certificate_types[:design_type] })
        .where(name: ['Urban Connectivity', 'Site', 'Materials', 'Management & Operations'])
        .update_all(shared:  true)
  end

  def down
    remove_column :scheme_categories, :shared
  end

end
