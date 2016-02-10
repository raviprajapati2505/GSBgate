class AddRenovationToIndexForSchemesTable < ActiveRecord::Migration
  def up
    remove_index :schemes, [:name, :gsas_version, :certificate_id]
    # custom name, because default generated name is too long
    add_index :schemes, [:name, :gsas_version, :certificate_id, :renovation], unique: true, name: 'index_schemes_on_name_gsasversion_certificateid_renovation'
  end

  def down
    remove_index :schemes, name: 'index_schemes_on_name_gsasversion_certificateid_renovation'
    add_index :schemes, [:name, :gsas_version, :certificate_id], unique: true
  end
end
