typology = 
  BuildingTypeGroup.find_or_create_by!(
    name: 'Typology', 
    visible: true
  )
  BuildingType.find_or_create_by!(name: 'Railway Station', visible: false, building_type_group: typology)
  BuildingType.find_or_create_by!(name: 'Railway Network', visible: false, building_type_group: typology)
  BuildingType.find_or_create_by!(name: 'Passenger Terminal', visible: false, building_type_group: typology)
  BuildingType.find_or_create_by!(name: 'Small Station', visible: true, building_type_group: typology)
  BuildingType.find_or_create_by!(name: 'Major Station', visible: true, building_type_group: typology)
  BuildingType.find_or_create_by!(name: 'Other', visible: true, building_type_group: typology)

puts "Building Type Groups are added successfully.........."

