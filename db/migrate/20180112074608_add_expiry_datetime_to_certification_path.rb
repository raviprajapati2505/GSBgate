class AddExpiryDatetimeToCertificationPath < ActiveRecord::Migration[4.2]
  def change
    add_column :certification_paths, :expires_at, :timestamp
    execute("update certification_paths set expires_at = (started_at + interval '1' year * duration)")
    remove_column :certification_paths, :duration
  end
end
