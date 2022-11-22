# create certification path assessment method records.
certification_path_ids = CertificationPath.joins(:certification_path_method).ids.uniq
certification_paths = CertificationPath.where.not(id: certification_path_ids)

certification_paths.each do |certification_path|
  certification_path.create_certification_path_method!(assessment_method: CertificationPath.assessment_methods["star_rating"])
end
