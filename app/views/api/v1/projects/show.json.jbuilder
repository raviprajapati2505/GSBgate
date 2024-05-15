json.id @project.id
json.project_code @project.code
json.name @project.name
json.owner @project.owner
json.description @project.description
json.building_type_group (@project.building_type_group.nil? ? nil : @project.building_type_group.name)
json.building_type (@project.building_type.nil? ? nil : @project.building_type.name)
json.address @project.address
json.lat_lng_wgs84 @project.coordinates
json.construction_year @project.construction_year
json.gross_area_square_meter @project.gross_area
json.certified_area_square_meter @project.certified_area
json.car_park_area_square_meter @project.carpark_area
json.plot_area_square_meter @project.project_site_area

json.certificates(@project.certification_paths) do |certification_path|
  json.type certification_path.certificate.certificate_type
  json.version certification_path.certificate.gsb_version
  json.certified_at certification_path.certified_at
  json.rating certification_path.rating_for_score(certification_path.scores_in_certificate_points[:achieved_score_in_certificate_points], certificate: certification_path.certificate)
  json.achieved_score certification_path.scores_in_certificate_points[:achieved_score_in_certificate_points]

  json.schemes(certification_path.scheme_mixes) do |scheme_mix|
    json.name scheme_mix.scheme.name
    json.main_scheme (certification_path.main_scheme_mix == scheme_mix)
    json.weight_percent scheme_mix.weight
    json.achieved_score scheme_mix.scores[:achieved_score_in_scheme_points]

    json.categories(scheme_mix.scheme_categories) do |scheme_category|
      json.name scheme_category.name
      json.code scheme_category.code
      json.weight_percent scheme_mix.scheme.weight_for_category(scheme_category)
      json.achieved_score sum_score_hashes(scheme_mix.scheme_mix_criteria_scores.group_by{|item| item[:scheme_category_id]}[scheme_category.id])[:achieved_score_in_scheme_points]

      # Assumption : only 1 criterion linked to Operations Energy category
      scheme_mix_criterion = scheme_mix.scheme_mix_criteria.for_category(scheme_category).first if scheme_category.code == 'E' || scheme_category.code == 'W'
    end
  end
end