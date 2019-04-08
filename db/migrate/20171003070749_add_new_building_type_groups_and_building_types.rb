class AddNewBuildingTypeGroupsAndBuildingTypes < ActiveRecord::Migration[4.2]
  def change
    # Main building types (level 0)
    BuildingTypeGroup.create!(id: 9, name: 'Healthcare')
    BuildingTypeGroup.create!(id: 10, name: 'Mosques')
    BuildingTypeGroup.create!(id: 11, name: 'Parks')
    BuildingTypeGroup.create!(id: 12, name: 'Group Residential')
    BuildingTypeGroup.create!(id: 13, name: 'Single Residential')
    BuildingTypeGroup.create!(id: 14, name: 'Workers Accommodation')

    # Sub building types (level 1)
    BuildingType.create!(id: 36, name: 'Clinics', building_type_group_id: 9)
    BuildingType.create!(id: 37, name: 'Hospital', building_type_group_id: 9)
    BuildingType.create!(id: 38, name: 'Laboratories', building_type_group_id: 9)
    BuildingType.create!(id: 39, name: 'Medical Research Centre', building_type_group_id: 9)

    BuildingType.create!(id: 40, name: 'Neighborhood Mosque', building_type_group_id: 10)
    BuildingType.create!(id: 41, name: 'Friday Mosque', building_type_group_id: 10)
    BuildingType.create!(id: 42, name: 'Eid Prayer Mosque', building_type_group_id: 10)

    BuildingType.create!(id: 43, name: 'Neighborhood Park', building_type_group_id: 11)
    BuildingType.create!(id: 44, name: 'District Park', building_type_group_id: 11)
    BuildingType.create!(id: 45, name: 'Water Park', building_type_group_id: 11)
    BuildingType.create!(id: 46, name: 'Open Land', building_type_group_id: 11)

    BuildingType.create!(id: 47, name: 'Apartments/ Flats Building', building_type_group_id: 12)

    BuildingType.create!(id: 48, name: 'Detached House/ Villa', building_type_group_id: 13)
    BuildingType.create!(id: 49, name: 'Semi Detached House', building_type_group_id: 13)
    BuildingType.create!(id: 50, name: 'Townhouse', building_type_group_id: 13)

    BuildingType.create!(id: 51, name: 'Single Bedroom Unit/ Studio', building_type_group_id: 14)
    BuildingType.create!(id: 52, name: 'Shared Bedroom Unit/ Dormitory Rooms', building_type_group_id: 14)
  end
end
