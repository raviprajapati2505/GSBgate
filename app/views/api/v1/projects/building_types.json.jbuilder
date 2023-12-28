json.building_types(@building_types) do |building_type|
  json.id building_type.id
  json.name building_type.name
  json.group_id building_type.building_type_group_id
end