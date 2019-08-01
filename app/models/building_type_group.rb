class BuildingTypeGroup < ApplicationRecord
  has_many :projects

  scope :visible, -> {
    where(visible: true)
  }
end