class RenameVersionToGsasVersion < ActiveRecord::Migration
  def up
    add_column :certificates, :gsas_version, :string
    add_column :schemes, :gsas_version, :string
    Certificate.update_all('gsas_version = version')
    Scheme.update_all('gsas_version = version')
    Certificate.where(gsas_version: nil).update_all("gsas_version = '2.1'")
    Scheme.where(gsas_version: nil).update_all("gsas_version = '2.1'")
    add_index :schemes, [:name, :gsas_version, :certificate_id], unique: true

    remove_index :schemes, [:name, :version, :certificate_id]
    remove_column :certificates, :version
    remove_column :schemes, :version
  end

  def down
    add_column :certificates, :version, :string
    add_column :schemes, :version, :string
    Certificate.update_all('version = gsas_version')
    Scheme.update_all('version = gsas_version')
    add_index :schemes, [:name, :gsas_version, :certificate_id], unique: true

    remove_index :schemes, [:name, :gsas_version, :certificate_id]
    remove_column :certificates, :gsas_version
    remove_column :schemes, :gsas_version
  end
end
