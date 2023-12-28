class AddBuildingTypeGroupsAndBuildingTypes < ActiveRecord::Migration[4.2]
  def change
    # Main building types (level 0)
    BuildingTypeGroup.create!(id: 1, name: 'Railways')
    BuildingTypeGroup.create!(id: 2, name: 'Sports')
    BuildingTypeGroup.create!(id: 3, name: 'Hotel')
    BuildingTypeGroup.create!(id: 4, name: 'Commercial')
    BuildingTypeGroup.create!(id: 5, name: 'Light Industry')
    BuildingTypeGroup.create!(id: 6, name: 'Education')
    BuildingTypeGroup.create!(id: 7, name: 'CORE + SHELL')
    BuildingTypeGroup.create!(id: 8, name: 'District & Infrastructure')

    # Sub building types (level 1)
    BuildingType.create!(id: 1, name: 'Railway Station', building_type_group_id: 1)
    BuildingType.create!(id: 2, name: 'Railway Network', building_type_group_id: 1)
    BuildingType.create!(id: 3, name: 'Passenger Terminal', building_type_group_id: 1)

    BuildingType.create!(id: 4, name: 'Sport Arena', building_type_group_id: 2)
    BuildingType.create!(id: 5, name: 'Sport Center', building_type_group_id: 2)
    BuildingType.create!(id: 6, name: 'Stadium', building_type_group_id: 2)
    BuildingType.create!(id: 7, name: 'Other', building_type_group_id: 2)
    BuildingType.create!(id: 8, name: 'Community Center', building_type_group_id: 2)

    BuildingType.create!(id: 9, name: 'Service Apartments', building_type_group_id: 3)
    BuildingType.create!(id: 10, name: 'Hotel', building_type_group_id: 3)

    BuildingType.create!(id: 11, name: 'Utility Building', building_type_group_id: 4)
    BuildingType.create!(id: 12, name: 'Theater', building_type_group_id: 4)
    BuildingType.create!(id: 13, name: 'Court', building_type_group_id: 4)
    BuildingType.create!(id: 14, name: 'Office', building_type_group_id: 4)
    BuildingType.create!(id: 15, name: 'Retail', building_type_group_id: 4)
    BuildingType.create!(id: 16, name: 'Restaurant', building_type_group_id: 4)
    BuildingType.create!(id: 17, name: 'Library', building_type_group_id: 4)
    BuildingType.create!(id: 18, name: 'Museum or Gallery', building_type_group_id: 4)

    BuildingType.create!(id: 19, name: 'Warehouse', building_type_group_id: 5)
    BuildingType.create!(id: 20, name: 'Workshop', building_type_group_id: 5)
    BuildingType.create!(id: 21, name: 'Industrial Process Building', building_type_group_id: 5)
    BuildingType.create!(id: 22, name: 'Other', building_type_group_id: 5)

    BuildingType.create!(id: 23, name: 'University / College', building_type_group_id: 6)
    BuildingType.create!(id: 24, name: 'Primary School', building_type_group_id: 6)
    BuildingType.create!(id: 25, name: 'Secondary School', building_type_group_id: 6)
    BuildingType.create!(id: 26, name: 'Other', building_type_group_id: 6)

    BuildingType.create!(id: 27, name: 'Shopping Mall', building_type_group_id: 7)
    BuildingType.create!(id: 28, name: 'Other', building_type_group_id: 7)

    BuildingType.create!(id: 29, name: 'Neighborhood', building_type_group_id: 8)
    BuildingType.create!(id: 30, name: 'Sport', building_type_group_id: 8)
    BuildingType.create!(id: 31, name: 'Healthcare', building_type_group_id: 8)
    BuildingType.create!(id: 32, name: 'Industrial', building_type_group_id: 8)
    BuildingType.create!(id: 33, name: 'Entertainment', building_type_group_id: 8)
    BuildingType.create!(id: 34, name: 'Education', building_type_group_id: 8)
    BuildingType.create!(id: 35, name: 'Transportation', building_type_group_id: 8)
  end
end
