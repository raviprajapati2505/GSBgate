class BuildingType < ApplicationRecord
  has_many :projects
  belongs_to :building_type_group, optional: true
end