class ProjectRenderingImage < ApplicationRecord
  belongs_to :certification_path, optional: true
  belongs_to :project
  mount_uploader :rendering_image, ImageUploader
end
