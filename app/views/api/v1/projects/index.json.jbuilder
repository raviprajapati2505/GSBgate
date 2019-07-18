json.projects(@projects) do |project|
  json.id project.id
  json.name project.name
  json.lat_lng_wgs84 project.coordinates
  json.construction_year project.construction_year
  json.gross_area_square_meter project.gross_area
  json.certified_area_square_meter project.certified_area
  json.car_park_area_square_meter project.carpark_area
  json.plot_area_square_meter project.project_site_area

  json.main_scheme_name (project.most_important_scheme_mix.nil? ? nil : project.most_important_scheme_mix.scheme.name)
  json.categories(project.categories) do |category_hash|
    json.code category_hash[0]
    json.achieved_score category_hash[1]['achieved_score']
    unless category_hash[1]['EPL_band'].nil?
      json.set! 'EPL_band' do
        category_hash[1]['EPL_band'].each do |epl_band|
          json.set! epl_band[:label], epl_band[:band]
        end
      end
    end
    unless category_hash[1]['WPL_band'].nil?
      json.set! 'WPL_band' do
        category_hash[1]['WPL_band'].each do |wpl_band|
          json.set! wpl_band[:label], wpl_band[:band]
        end
      end
    end
  end
end
# json.total_energy_consumption @total_energy_consumption
json.total_as_built_energy_consumption (@total_as_built_cooling_consumption + @total_as_built_lighting_consumption + @total_as_built_auxiliaries_consumption + @total_as_built_dhw_consumption + @total_as_built_others_consumption + @total_as_built_generation_consumption + @total_as_built_co2_emission).to_f
json.total_as_operated_energy_consumption (@total_as_operated_cooling_consumption + @total_as_operated_lighting_consumption + @total_as_operated_auxiliaries_consumption + @total_as_operated_dhw_consumption + @total_as_operated_others_consumption + @total_as_operated_generation_consumption + @total_as_operated_co2_emission).to_f
json.total_as_built_cooling_consumption @total_as_built_cooling_consumption.to_f
json.total_as_operated_cooling_consumption @total_as_operated_cooling_consumption.to_f
json.total_as_built_lighting_consumption @total_as_built_lighting_consumption.to_f
json.total_as_operated_lighting_consumption @total_as_operated_lighting_consumption.to_f
json.total_as_built_auxiliaries_consumption @total_as_built_auxiliaries_consumption.to_f
json.total_as_operated_auxiliaries_consumption @total_as_operated_auxiliaries_consumption.to_f
json.total_as_built_dhw_consumption @total_as_built_dhw_consumption.to_f
json.total_as_operated_dhw_consumption @total_as_operated_dhw_consumption.to_f
json.total_as_built_others_consumption @total_as_built_others_consumption.to_f
json.total_as_operated_others_consumption @total_as_operated_others_consumption.to_f
json.total_as_built_generation_consumption @total_as_built_generation_consumption.to_f
json.total_as_operated_generation_consumption @total_as_operated_generation_consumption.to_f
json.total_as_built_co2_emission @total_as_built_co2_emission.to_f
json.total_as_operated_co2_emission @total_as_operated_co2_emission.to_f

# json.total_water_consumption @total_water_consumption
json.total_as_built_water_consumption (@total_as_built_indoor_use_consumption + @total_as_built_irrigation_consumption + @total_as_built_cooling_tower_consumption).to_f
json.total_as_operated_water_consumption (@total_as_operated_indoor_use_consumption + @total_as_operated_irrigation_consumption + @total_as_operated_cooling_tower_consumption).to_f
json.total_as_built_indoor_use_consumption @total_as_built_indoor_use_consumption.to_f
json.total_as_operated_indoor_use_consumption @total_as_operated_indoor_use_consumption.to_f
json.total_as_built_irrigation_consumption @total_as_built_irrigation_consumption.to_f
json.total_as_operated_irrigation_consumption @total_as_operated_irrigation_consumption.to_f
json.total_as_built_cooling_tower_consumption @total_as_built_cooling_tower_consumption.to_f
json.total_as_operated_cooling_tower_consumption @total_as_operated_cooling_tower_consumption.to_f

json.project_count @project_count
json.current_page @page
json.page_count @page_count