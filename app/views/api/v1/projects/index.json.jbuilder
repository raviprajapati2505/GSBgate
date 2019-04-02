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
    json.achieved_score category_hash[1]
  end
end