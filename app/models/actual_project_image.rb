class ActualProjectImage < ApplicationRecord
  belongs_to :project, optional: true
  mount_uploader :actual_image, ImageUploader
end
