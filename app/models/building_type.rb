class BuildingType < ActiveRecord::Base
  has_many :projects
  belongs_to :building_type_group
end