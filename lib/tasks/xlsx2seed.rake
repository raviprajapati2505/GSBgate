namespace :xlsx2seed do

  require 'roo'

  LETTER_OF_CONFORMANCE = 'Letter of Conformance'
  FINAL_DESIGN = 'Final Design Certificate'
  CONSTRUCTION = 'Construction Certificate'
  OPERATIONS = 'Operations Certificate'

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
          # Skip Final Design rows
          if certificate_name != FINAL_DESIGN
            requirement_identifier = writeCreateRequirementLine(seeds_file, requirement_text, current_col_index, version, certificate_index, typology_name, renovation, category_name, criterion_index)
            writeCreateSchemeCriteriaRequirementLine(seeds_file, requirement_identifier, category_name, typology_name, version, renovation, certificate_name, criterion_name)

            # LOC and Final Design are identical
            if certificate_name == LETTER_OF_CONFORMANCE
              certificate_name_2 = FINAL_DESIGN
              certificate_index_2 = certificates.index(certificate_name_2)
              if certificate_index_2.nil?
                certificate_index_2 = certificates.length
                certificates << certificate_name_2
              end
              requirement_identifier = writeCreateRequirementLine(seeds_file, requirement_text, current_col_index, version, certificate_index_2, typology_name, renovation, category_name, criterion_index)
              writeCreateSchemeCriteriaRequirementLine(seeds_file, requirement_identifier, category_name, typology_name, version, renovation, certificate_name_2, criterion_name)
            end
          end

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

  def writeCreateRequirementLine(seeds_file, requirement_text, current_col_index, version, certificate_index, typology_name, renovation, category_name, criterion_index)
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
    return requirement_identifier
  end

  def writeCreateSchemeCriteriaRequirementLine(seeds_file, requirement_identifier, category_name, typology_name, version, renovation, certificate_name, criterion_name)
    certificate_scopes = {CONSTRUCTION => 'construction_certificate',
                          FINAL_DESIGN => 'final_design_certificate',
                          LETTER_OF_CONFORMANCE => 'letter_of_conformance',
                          OPERATIONS => 'operations_certificate'}

    text_line = "SchemeCriteriaRequirement.create!(requirement: #{requirement_identifier}, scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(name: \"#{category_name}\", scheme: Scheme.find_by(name: \"#{typology_name}\", gsas_version: \"#{version}\", renovation: #{renovation}, certificate: Certificate.#{certificate_scopes[certificate_name]})), name: \"#{criterion_name}\"))\n"
    # write create scheme criteria requirement statement
    seeds_file << text_line
    Rails.logger.info text_line
  end
end