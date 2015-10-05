class AddAppealedToCertificationPath < ActiveRecord::Migration
  def change
    add_column :certification_paths, :appealed, :boolean, default: false
  end
end
