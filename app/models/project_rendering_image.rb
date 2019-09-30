class ProjectRenderingImage < ApplicationRecord
  belongs_to :project
  mount_uploader :rendering_image, ImageUploader
end
