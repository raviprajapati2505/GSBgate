namespace :xlsx2seed do

  require 'roo'

  desc "Converts xlsx file to seeds file"
  task :convert, [:input_filename, :output_filename] => :environment do |t, args|
    Rails.logger = Logger.new(STDOUT)

    if args.input_filename.blank? || args.output_filename.blank?
      Rails.logger.error 'usage : rake xlsx2seed:convert[<input_filename>,<output_filename>]'
      Rails.logger.error ' e.g. : rake xlsx2seed:convert[RequirementsTemplate.xlsx,db/seeds/requirements.rb]'
      exit
    end
    Rails.logger.info "#{args}"

    seeds_file = File.new(args.output_filename, 'w+')

    xlsx = Roo::Spreadsheet.open(args.input_filename)
    sheet = xlsx.sheet(0)

    certificate_scopes = {'Construction Certificate' => 'construction_certificate',
                          'GSAS Design Certificate' => 'final_design_certificate',
                          'Letter of Conformance' => 'letter_of_conformance',
                          'Operations Certificate' => 'operations_certificate'}

    certificates = []
    criteria = []

    missing_requirements_count = 0
    first_row_index = sheet.first_row
    last_row_index = sheet.last_row
    current_row_index = first_row_index + 1
    while current_row_index <= last_row_index

      version = sheet.cell(current_row_index, 'A')
      certificate_name = sheet.cell(current_row_index, 'B')
      typology_name = sheet.cell(current_row_index, 'C')
      renovation = sheet.cell(current_row_index, 'D')
      category_name = sheet.cell(current_row_index, 'E')
      # criterion_code = sheet.cell(current_row_index, 'F')
      criterion_name = sheet.cell(current_row_index, 'G')

      certificate_index = certificates.index(certificate_name)
      if certificate_index.nil?
        certificate_index = certificates.length
        certificates << certificate_name
      end

      criterion_index = criteria.index(criterion_name)
      if criterion_index.nil?
        criterion_index = criteria.length
        criteria << criterion_name
      end

      current_col_index = 1
      begin
        requirement_text = sheet.cell(current_row_index, 7 + current_col_index)
        if requirement_text.present?
          requirement_identifier = "REQUIREMENT_#{current_col_index}_FOR_V#{version}_CERTIFICATE_#{certificate_index}_SCHEME_#{typology_name}_#{renovation}_CATEGORY_#{category_name}_CRITERION_#{criterion_index}"
          requirement_identifier.gsub!(' ', '_')
          requirement_identifier.gsub!('.', '_')
          requirement_identifier.gsub!('-', '_')
          requirement_identifier.gsub!('+', '_')
          requirement_identifier.gsub!('&', '_')
          requirement_identifier.strip!
          requirement_text.gsub!(/\n/, ' ')
          text_line = "#{requirement_identifier} = Requirement.create!(name: \"#{requirement_text}\")\n"
          # write create requirement statement
          seeds_file << text_line
          Rails.logger.info text_line

          text_line = "SchemeCriteriaRequirement.create!(requirement: #{requirement_identifier}, scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(name: \"#{category_name}\", scheme: Scheme.find_by(name: \"#{typology_name}\", gsas_version: \"#{version}\", renovation: #{renovation}, certificate: Certificate.#{certificate_scopes[certificate_name]})), name: \"#{criterion_name}\"))\n"
          # write create scheme criteria requirement statement
          seeds_file << text_line
          Rails.logger.info text_line

          current_col_index += 1
        end
      end while requirement_text.present?

      if current_col_index == 1
        missing_requirements_count += 1
        Rails.logger.warn "No requirements found for row #{current_row_index}!"
      end

      current_row_index += 1
    end

    seeds_file.close

    if missing_requirements_count > 0
      Rails.logger.warn("#{missing_requirements_count} rows without requirements found!")
    end
  end
end