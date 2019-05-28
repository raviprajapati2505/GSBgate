namespace :xlsx2seed do

  require 'roo'
  require 'axlsx'

  desc "Creates xlsx file for operations v2019 criteria which can be completed with requirements"
  task :generate, [:output_filename] => :environment do |t, args|
    Rails.logger = Logger.new(STDOUT)

    if args.output_filename.blank?
      Rails.logger.error 'usage : rake xlsx2seed:generate[<output_filename>]'
      Rails.logger.error ' e.g. : rake xlsx2seed:generate[RequirementsTemplate.xlsx]'
      exit
    end
    Rails.logger.info "#{args}"

    p = Axlsx::Package.new
    wb = p.workbook
    wb.styles do |style|
      blue_cell = style.add_style bg_color: "9bbb59", b: true

      wb.add_worksheet(name: 'requirements') do |sheet|
        sheet.add_row ['scheme ID', 'category ID', 'criterion ID', 'version', 'certificate', 'scheme', 'renovation', 'category', 'criterion number', 'criterion name', 'requirement 1', 'requirement 2', 'requirement 3', 'requirement 4', 'requirement 5', 'requirement 6', 'requirement 7', 'requirement 8', 'requirement 9', 'requirement 10', 'requirement 11', 'requirement 12', 'requirement 13', 'requirement 14', 'requirement 15'], style: blue_cell

        scheme_criteria = SchemeCriterion.joins(scheme_category: [scheme: [development_types: [:certificate]]]).distinct.select('scheme_criteria.id as crit_id, scheme_criteria.name as crit_name, scheme_criteria.number, scheme_categories.id as cat_id, scheme_categories.name as cat_name, scheme_categories.code, schemes.id as s_id, schemes.name as s_name, schemes.renovation, certificates.name as c_name, certificates.gsas_version').where(certificates: {certificate_type: Certificate.certificate_types[:operations_type], gsas_version: '2019'}).order('schemes.id, scheme_categories.id, scheme_criteria.id')
        scheme_criteria.each do |scheme_criterion|
          row_cells = []
          row_cells << scheme_criterion['s_id']
          row_cells << scheme_criterion['cat_id']
          row_cells << scheme_criterion['crit_id']
          row_cells << scheme_criterion['gsas_version']
          row_cells << scheme_criterion['c_name']
          row_cells << scheme_criterion['s_name']
          row_cells << scheme_criterion['renovation']
          row_cells << scheme_criterion['cat_name']
          row_cells << "#{scheme_criterion['code']}.#{scheme_criterion['number']}"
          row_cells << scheme_criterion['crit_name']
          sheet.add_row row_cells
        end

        # last_row_index = sheet.rows.last.index + 1
        # sheet.auto_filter = "A1:J#{last_row_index}"
      end
    end

    p.serialize(args.output_filename)

  end

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

      certificate_name = sheet.cell(current_row_index, 'E')

      # Ignore Construction Management stage 2 & 3 to prevent duplicate requirements
      unless ['Construction Certificate (sub- and superstructure stage:2)', 'Construction Certificate (finishing stage:3)'].include?(certificate_name)
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
      end

      current_row_index += 1
    end

    seeds_file.close

    if missing_requirements_count > 0
      Rails.logger.warn("#{missing_requirements_count} rows without requirements found!")
    end
  end

  def writeCreateRequirementLine(seeds_file, requirement_text, current_col_index, scheme_criteria_id)
    requirement_identifier = "requirement_#{current_col_index}_for_scheme_criterion_id_#{scheme_criteria_id}"
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