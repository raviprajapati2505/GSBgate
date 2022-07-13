require 'roo'

@certificate_names = 
  {
    "Letter of Conformance" => "Stage 1: LOC, Design Certificate",
    "Final Design Certificate" => "Stage 2: CDA, Design & Build Certificate"
  }

# create project
def create_project(i, row)
  project = 
    Offline::Project.find_or_initialize_by(
      code: row["Project Code"]&.to_s,
      name: row["Project Name"]&.to_s
    )

  project.certificate_type = Certificate.certificate_types[:design_type]
  project.certified_area = row["Project Certified Area"]&.to_s
  project.site_area = row["Project Site Area"]&.to_s
  project.developer = row["Project Developer"]&.to_s

  unless project.save
    @errors << "Row: #{i}, Project Error: #{project.errors.full_messages}"
  end

  return project
end

# create certification path
def create_certfication_path(i, row, project)
  if project.persisted?

    certificate_name = row["Certification Name"].split(",")[0]
    certificate_verison = row["Certification Name"].split(",")[1]

    certification_path = 
      project.
        offline_certification_paths.
        find_or_initialize_by(
          name: @certificate_names[certificate_name]&.strip
        )

      certification_path.version = certificate_verison&.strip
      certification_path.development_type = row["Certification Development Type"]&.titleize
      certification_path.status = row["Certification Status"]&.titleize
      certification_path.rating = row["Certification Rating"]&.titleize

    unless certification_path.save
      @errors << "Row: #{i}, Project Error: #{certification_path.errors.full_messages}"
    end
  end

  return certification_path
end

# create scheme mix
def create_scheme_mix(i, row, certification_path)
  if row["Certification Scheme"]&.strip.present? && certification_path.persisted?
    scheme_mix = 
      certification_path.
      offline_scheme_mixes.
      find_or_initialize_by(
        name: row["Certification Scheme"]&.strip&.titleize
      )

    scheme_mix.weight = '100'

    unless scheme_mix.save
      errors << "Row: #{i}, Project Error: #{scheme_mix.errors.full_messages}"
    end
  end

  return scheme_mix
end

# import projects
xlsx = Roo::Excelx.new("#{Rails.root}/db/imports/certified_offline_projects.xlsx", extension: :xlsx)
header = xlsx.row(1)

xlsx.each_with_pagename do |name, sheet|
  if(name == 'offline_projects')
    @errors = []

    (2..xlsx.last_row).each do |i|
      row = Hash[[header, xlsx.row(i)].transpose]

      begin
        project = create_project(i, row)
        certification_path = create_certfication_path(i, row, project)
        scheme_mix = create_scheme_mix(i, row, certification_path)

      rescue => e
        @errors << "Row: #{i}, General Error: #{e.message}"
      end
    end

    puts @errors
  end
end
