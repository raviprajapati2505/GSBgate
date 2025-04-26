class RemoveTrustFromDemeritFlags < ActiveRecord::Migration[7.0]
  def change
    rename_column :demerit_flags, :gsb_trust_notification, :gsb_notification
  end
end
