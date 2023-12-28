class UpdateBuildingTypeGroupAndBuildingTypeList < ActiveRecord::Migration[5.2]
  def change
    # Building Type Groups
    BuildingTypeGroup.find_by(id: 3, name: 'Hotel').update_column(:visible, false)
    BuildingTypeGroup.find_by(id: 7, name: 'CORE + SHELL').update_column(:visible, false)
    BuildingTypeGroup.find_by(id: 12, name: 'Group Residential').update_column(:visible, false)
    BuildingTypeGroup.find_by(id: 13, name: 'Single Residential').update_column(:visible, false)
    BuildingTypeGroup.find_by(id: 8, name: 'District & Infrastructure').update_column(:name, 'Districts')
    BuildingTypeGroup.create!(id: 15, name: 'Homes')
    BuildingTypeGroup.create!(id: 16, name: 'Hospitality')
    BuildingTypeGroup.create!(id: 17, name: 'Offices')
    BuildingTypeGroup.create!(id: 18, name: 'Residential')
    BuildingTypeGroup.create!(id: 19, name: 'Neighborhood')
    BuildingTypeGroup.create!(id: 20, name: 'Energy Center')
    BuildingTypeGroup.create!(id: 21, name: 'Bespoke')

    # Railways
    BuildingType.find_by(id: 1, building_type_group_id: 1, name: 'Railway Station').update_column(:visible, false)
    BuildingType.find_by(id: 2, building_type_group_id: 1, name: 'Railway Network').update_column(:visible, false)
    BuildingType.find_by(id: 3, building_type_group_id: 1, name: 'Passenger Terminal').update_column(:visible, false)
    BuildingType.create!(id: 53, building_type_group_id: 1, name: 'Small Station')
    BuildingType.create!(id: 54, building_type_group_id: 1, name: 'Major Station')
    BuildingType.create!(id: 55, building_type_group_id: 1, name: 'Other')

    # Sports
    BuildingType.find_by(id: 4, building_type_group_id: 2, name: 'Sport Arena').update_column(:visible, false)
    BuildingType.find_by(id: 5, building_type_group_id: 2, name: 'Sport Center').update_column(:visible, false)
    BuildingType.find_by(id: 8, building_type_group_id: 2, name: 'Community Center').update_column(:visible, false)
    BuildingType.create!(id: 56, building_type_group_id: 2, name: 'Multi-Purpose Hall')
    BuildingType.create!(id: 57, building_type_group_id: 2, name: 'Fitness/Leisure Center')
    BuildingType.create!(id: 58, building_type_group_id: 2, name: 'Swimming Pool Hall')

    # Hotel
    BuildingType.find_by(id: 9, building_type_group_id: 3, name: 'Service Apartments').update_column(:visible, false)
    BuildingType.find_by(id: 10, building_type_group_id: 3, name: 'Hotel').update_column(:visible, false)

    # Commercial
    BuildingType.find_by(id: 11, building_type_group_id: 4, name: 'Utility Building').update_column(:visible, false)
    BuildingType.find_by(id: 12, building_type_group_id: 4, name: 'Theater').update_column(:visible, false)
    BuildingType.find_by(id: 13, building_type_group_id: 4, name: 'Court').update_column(:visible, false)
    BuildingType.find_by(id: 14, building_type_group_id: 4, name: 'Office').update_column(:visible, false)
    BuildingType.find_by(id: 17, building_type_group_id: 4, name: 'Library').update_column(:visible, false)
    BuildingType.find_by(id: 18, building_type_group_id: 4, name: 'Museum or Gallery').update_column(:visible, false)
    BuildingType.create!(id: 59, building_type_group_id: 4, name: 'Shopping Mall')
    BuildingType.create!(id: 60, building_type_group_id: 4, name: 'Other')

    # Education
    BuildingType.find_by(id: 24, building_type_group_id: 6, name: 'Primary School').update_column(:visible, false)
    BuildingType.find_by(id: 25, building_type_group_id: 6, name: 'Secondary School').update_column(:visible, false)
    BuildingType.create!(id: 61, building_type_group_id: 6, name: 'Day Care')
    BuildingType.create!(id: 62, building_type_group_id: 6, name: 'School K-12')

    # CORE + SHELL
    BuildingType.find_by(id: 27, building_type_group_id: 7, name: 'Shopping Mall').update_column(:visible, false)
    BuildingType.find_by(id: 28, building_type_group_id: 7, name: 'Other').update_column(:visible, false)

    # Districts
    BuildingType.find_by(id: 29, building_type_group_id: 8, name: 'Neighborhood').update_column(:visible, false)
    BuildingType.find_by(id: 35, building_type_group_id: 8, name: 'Transportation').update_column(:visible, false)
    BuildingType.find_by(id: 30, building_type_group_id: 8, name: 'Sport').update_column(:name, 'Sports')
    BuildingType.create!(id: 63, building_type_group_id: 8, name: 'Media')
    BuildingType.create!(id: 64, building_type_group_id: 8, name: 'Mixed-Use')
    BuildingType.create!(id: 65, building_type_group_id: 8, name: 'Residential')
    BuildingType.create!(id: 66, building_type_group_id: 8, name: 'Other')

    # Healthcare
    BuildingType.find_by(id: 36, building_type_group_id: 9, name: 'Clinics').update_column(:visible, false)
    BuildingType.find_by(id: 38, building_type_group_id: 9, name: 'Laboratories').update_column(:visible, false)
    BuildingType.create!(id: 67, building_type_group_id: 9, name: 'Healthcare Center/Outpatient Clinic')
    BuildingType.create!(id: 68, building_type_group_id: 9, name: 'Pharmacy/Laboratory')
    BuildingType.create!(id: 103, building_type_group_id: 9, name: 'Other')

    # Mosques
    BuildingType.find_by(id: 40, building_type_group_id: 10, name: 'Neighborhood Mosque').update_column(:visible, false)
    BuildingType.find_by(id: 42, building_type_group_id: 10, name: 'Eid Prayer Mosque').update_column(:visible, false)
    BuildingType.create!(id: 69, building_type_group_id: 10, name: 'Daily Prayers Mosque')
    BuildingType.create!(id: 70, building_type_group_id: 10, name: 'Other')

    # Parks
    BuildingType.find_by(id: 43, building_type_group_id: 11, name: 'Neighborhood Park').update_column(:visible, false)
    BuildingType.find_by(id: 44, building_type_group_id: 11, name: 'District Park').update_column(:visible, false)
    BuildingType.find_by(id: 46, building_type_group_id: 11, name: 'Open Land').update_column(:visible, false)
    BuildingType.create!(id: 71, building_type_group_id: 11, name: 'Mini Park')
    BuildingType.create!(id: 72, building_type_group_id: 11, name: 'Community Park')
    BuildingType.create!(id: 73, building_type_group_id: 11, name: 'Special-Use Park')
    BuildingType.create!(id: 74, building_type_group_id: 11, name: 'Other')

    # Group Residential
    BuildingType.find_by(id: 47, building_type_group_id: 12, name: 'Apartments/ Flats Building').update_column(:visible, false)

    # Single Residential
    BuildingType.find_by(id: 48, building_type_group_id: 13, name: 'Detached House/ Villa').update_column(:visible, false)
    BuildingType.find_by(id: 49, building_type_group_id: 13, name: 'Semi Detached House').update_column(:visible, false)
    BuildingType.find_by(id: 50, building_type_group_id: 13, name: 'Townhouse').update_column(:visible, false)

    # Workers Accomodation
    BuildingType.find_by(id: 51, building_type_group_id: 14, name: 'Single Bedroom Unit/ Studio').update_column(:visible, false)
    BuildingType.find_by(id: 52, building_type_group_id: 14, name: 'Shared Bedroom Unit/ Dormitory Rooms').update_column(:visible, false)
    BuildingType.create!(id: 75, building_type_group_id: 14, name: 'Workers Accommodation')
    BuildingType.create!(id: 76, building_type_group_id: 14, name: 'Other')

    # Homes
    BuildingType.create!(id: 77, building_type_group_id: 15, name: 'Home')
    BuildingType.create!(id: 78, building_type_group_id: 15, name: 'Other')

    # Hospitality
    BuildingType.create!(id: 79, building_type_group_id: 16, name: 'Hotel (5 Star)')
    BuildingType.create!(id: 80, building_type_group_id: 16, name: 'Hotel (1-4 Star)')
    BuildingType.create!(id: 81, building_type_group_id: 16, name: 'Service Apartments')
    BuildingType.create!(id: 82, building_type_group_id: 16, name: 'Other')

    # Offices
    BuildingType.create!(id: 83, building_type_group_id: 17, name: 'Professional Services Office')
    BuildingType.create!(id: 84, building_type_group_id: 17, name: 'Public Building')
    BuildingType.create!(id: 85, building_type_group_id: 17, name: 'Other')

    # Residential
    BuildingType.create!(id: 86, building_type_group_id: 18, name: 'Apartments')
    BuildingType.create!(id: 87, building_type_group_id: 18, name: 'Other')

    # Neighbourhood
    BuildingType.create!(id: 88, building_type_group_id: 19, name: 'Education')
    BuildingType.create!(id: 89, building_type_group_id: 19, name: 'Entertainment')
    BuildingType.create!(id: 90, building_type_group_id: 19, name: 'Healthcare')
    BuildingType.create!(id: 91, building_type_group_id: 19, name: 'Industrial')
    BuildingType.create!(id: 92, building_type_group_id: 19, name: 'Media')
    BuildingType.create!(id: 93, building_type_group_id: 19, name: 'Sports')
    BuildingType.create!(id: 94, building_type_group_id: 19, name: 'Mixed-Use')
    BuildingType.create!(id: 95, building_type_group_id: 19, name: 'Residential')
    BuildingType.create!(id: 96, building_type_group_id: 19, name: 'Other')

    # Energy Center
    BuildingType.create!(id: 97, building_type_group_id: 20, name: 'Energy Center')

    # Bespoke
    BuildingType.create!(id: 98, building_type_group_id: 21, name: 'Airport terminal')
    BuildingType.create!(id: 99, building_type_group_id: 21, name: 'Bus Stops')
    BuildingType.create!(id: 100, building_type_group_id: 21, name: 'Car Park')
    BuildingType.create!(id: 101, building_type_group_id: 21, name: 'Port/Custom Terminal')
    BuildingType.create!(id: 102, building_type_group_id: 21, name: 'Other')
  end
end
