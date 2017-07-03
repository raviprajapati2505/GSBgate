class CleanUpUploadGeneralSubmittalsTasks < ActiveRecord::Migration
  def change
    # Clean up all PROJ_MNGR_GEN tasks since they are obsolete as of now
    Task.where(task_description_id: Taskable::PROJ_MNGR_GEN).destroy_all
  end
end
