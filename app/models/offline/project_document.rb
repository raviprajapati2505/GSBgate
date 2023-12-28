module Offline
  class ProjectDocument < ApplicationRecord
    MAXIMUM_DOCUMENT_FILE_SIZE = 100 # in MB

    mount_uploader :document_file, OfflineProjectsDocumentUploader

    belongs_to :offline_project, class_name: 'Offline::Project', foreign_key: 'offline_project_id', inverse_of: :offline_project_documents

    validates :document_file, presence: true

    def content_type
      document_file&.file&.content_type
    end

    def file_name
      document_file&.file&.filename
    end

    def file_size
      document_file&.file&.size
    end
  end
end
