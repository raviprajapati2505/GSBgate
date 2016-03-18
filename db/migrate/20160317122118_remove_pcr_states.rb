class RemovePcrStates < ActiveRecord::Migration
  def change
    CertificationPathStatus.where(name: ['Processing PCR payment', 'Submitting PCR']).delete_all
    NotificationType.where(name: ['PCR for Certificate selected', 'PCR for Certificate approved', 'PCR option was requested', 'PCR options was canceled', 'PCR option was granted', 'PCR option was rejected']).delete_all
    remove_column :certification_paths, :pcr_track_allowed
    add_column :scheme_mix_criteria, :in_review, :boolean, default: false
  end
end
