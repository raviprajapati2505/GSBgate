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

    missing_requirements_count = 0
    first_row_index = sheet.first_row
    last_row_index = sheet.last_row
    current_row_index = first_row_index + 1
    while current_row_index <= last_row_index

      scheme_criteria_id = sheet.cell(current_row_index, 'C')

      current_col_index = 1
      begin
        requirement_text = sheet.cell(current_row_index, 10 + current_col_index)
        if requirement_text.present?
          requirement_identifier = writeCreateRequirementLine(seeds_file, requirement_text, current_col_index, scheme_criteria_id)
          writeCreateSchemeCriteriaRequirementLine(seeds_file, requirement_identifier, scheme_criteria_id)

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

  def writeCreateRequirementLine(seeds_file, requirement_text, current_col_index, scheme_criteria_id)
    requirement_identifier = "REQUIREMENT_#{current_col_index}_FOR_SCHEME_CRITERIA_ID_#{scheme_criteria_id}"
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

  def writeCreateSchemeCriteriaRequirementLine(seeds_file, requirement_identifier, scheme_criteria_id)
    text_line = "SchemeCriteriaRequirement.create!(requirement: #{requirement_identifier}, scheme_criterion: SchemeCriterion.find_by(id: #{scheme_criteria_id}))\n"
    # write create scheme criteria requirement statement
    seeds_file << text_line
    Rails.logger.info text_line
  end
end