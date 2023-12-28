class AddAppealedToCertificationPath < ActiveRecord::Migration[4.2]
  def change
    add_column :certification_paths, :appealed, :boolean, default: false
  end
end
