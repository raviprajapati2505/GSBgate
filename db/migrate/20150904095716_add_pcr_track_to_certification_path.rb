class AddPcrTrackToCertificationPath < ActiveRecord::Migration[4.2]
  def change
    add_column :certification_paths, :pcr_track, :boolean, default: false
    add_column :certification_paths, :pcr_track_allowed, :boolean, default: false
  end
end
