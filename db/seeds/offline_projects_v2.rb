require 'roo'

# create project
def create_project(i, row)
  project = 
    Offline::Project.find_or_initialize_by(
      code: row["Project ID"]&.to_s || "TBC"
    )

  project.certificate_type = Offline::Project.certificate_types[row["Certification Type"]&.strip]
  project.assessment_type = Offline::Project.assessment_types[row["Certification Method"]&.strip]
  project.certified_area = row["Project Certified Area"]&.to_s
  project.plot_area = row["Project Plot Area"]&.to_s
  project.owner = row["Project Owner"]&.to_s
  project.developer = row["Project Developer"]&.to_s
  project.project_country = row["Project Country"]&.to_s
  project.project_city = row["Project City"]&.to_s
  project.project_district = row["Project District"]&.to_s
  project.project_owner_business_sector = row["Project Owner Business Sector"]&.to_s
  project.project_developer_business_sector = row["Project Developer Business Sector"]&.to_s
  project.project_gross_built_up_area = row["Project Gross Built Up Area"]&.to_s

  unless project.save
    @errors << "Row: #{i}, Project Error: #{project.errors.full_messages}"
  end

  return project
end

# create certification path
def create_certfication_path(i, row, project)
  certification_path = 
    project.
      offline_certification_paths.
      find_or_initialize_by(
        name: row["Certification Stage"]&.strip,
        version: row["Certification Version"]&.strip
      )

    certification_path.development_type = row["Project Planning Type"]&.strip&.titleize
    certification_path.status = "Certified"
    certification_path.rating = row["Certification Rating"]&.strip&.titleize
    certification_path.score = row["Certification Score"]
    certification_path.certified_at = row["Certification Awarded On"]

  unless certification_path.save
    @errors << "Row: #{i}, Certification Path Error: #{certification_path.errors.full_messages}"
  end

  return certification_path
end

# create scheme mix
def create_scheme_mix(i, row, certification_path)
  if row["Certification Scheme"]&.strip.present?
    scheme_mix = 
      certification_path.
      offline_scheme_mixes.
      find_or_initialize_by(
        name: row["Certification Scheme"]&.strip&.titleize
      )

    scheme_mix.weight = '100'

    unless scheme_mix.save
      errors << "Row: #{i}, Scheme Mix Error: #{scheme_mix.errors.full_messages}"
    end
  end

  return scheme_mix
end

def create_scheme_mix_criteria(i, row, scheme_mix)
  # add blank column before scheme criteria columns in excel file
  starting_of_criteria_index = @header.find_index(nil) + 1

  (starting_of_criteria_index..@header.length).each do |j|
    if row[j].present?
      scheme_mix_criterion =
        scheme_mix.
          offline_scheme_mix_criteria.
          find_or_initialize_by(
            name: @header[j]&.strip,
            code: @header[j]&.strip
          )

      scheme_mix_criterion.score = row[j]
    end
  end

  unless scheme_mix.save
    errors << "Row: #{i}, Scheme Mix Criterion Error: #{scheme_mix_criterion.errors.full_messages}"
  end

  return true
end

# import projects
@xlsx = Roo::Excelx.new("#{Rails.root}/db/imports/certified_offline_projects_v2.xlsx", extension: :xlsx)

@xlsx.each_with_pagename do |name, sheet|
  if(name == '22022023')
    @errors = []
    @header = @xlsx.row(1)

    (2..@xlsx.last_row).each do |i|
      row = Hash[[@header, @xlsx.row(i)].transpose]

      begin
        project = create_project(i, row)
        certification_path = create_certfication_path(i, row, project) if project.persisted?
        scheme_mix = create_scheme_mix(i, row, certification_path) if certification_path.persisted?

      rescue => e
        @errors << "Row: #{i}, General Error: #{e.message}"
      end
    end

    puts @errors
  end
end
