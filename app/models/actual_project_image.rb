class ActualProjectImage < ApplicationRecord
  belongs_to :certification_path, optional: true
  belongs_to :project
  mount_uploader :actual_image, ImageUploader
end
