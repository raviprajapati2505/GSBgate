namespace :xlsx2seed do

  require 'roo'

  desc "Converts xlsx file to seeds file"
  task :convert, [:input_filename, :output_filename] => :environment do |t, args|
    Rails.logger = Logger.new(STDOUT)

    if args.input_filename.blank? || args.output_filename.blank?
      Rails.logger.error 'usage : rake xlsx2seed:convert[<input_filename>,<output_filename>]'
      Rails.logger.error ' e.g. : rake xlsx2seed:convert[RequirementsTemplate.xlsx,db/seeds/generated2.rb]'
      exit
    end
    Rails.logger.info "#{args}"

    seeds_file = File.new(args.output_filename, 'w+')

    xlsx = Roo::Spreadsheet.open(args.input_filename)
    sheet = xlsx.sheet(0)

    certificate_scopes = {'Construction Management Certificate' => 'construction_certificate',
                          'GSAS Design & Build Certificate' => 'final_design_certificate',
                          'Letter of Conformance' => 'letter_of_conformance',
                          'Operations Certificate' => 'operations_certificate'}

    certificates = []
    criteria = []

    first_row_index = sheet.first_row
    last_row_index = sheet.last_row
    current_row_index = first_row_index + 1
    while current_row_index <= last_row_index

      certificate_name = sheet.cell(current_row_index, 'A')
      # category_name = sheet.cell(current_row_index, 'B')
      category_code = sheet.cell(current_row_index, 'C')
      # criterion_code = sheet.cell(current_row_index, 'D')
      # criterion_number = sheet.cell(current_row_index, 'E')
      criterion_name = sheet.cell(current_row_index, 'F')
      typology_name = sheet.cell(current_row_index, 'G')

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
          requirement_identifier = "REQUIREMENT_#{current_col_index}_FOR_CERTIFICATE_#{certificate_index}_SCHEME_#{typology_name}_CATEGORY_#{category_code}_CRITERION_#{criterion_index}"
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

          text_line = "SchemeCriteriaRequirement.create!(requirement: #{requirement_identifier}, scheme_criterion: SchemeCriterion.find_by(scheme_category: SchemeCategory.find_by(code: \"#{category_code}\", scheme: Scheme.find_by(name: \"#{typology_name}\", version: \"2.1\", certificate: Certificate.#{certificate_scopes[certificate_name]})), name: \"#{criterion_name}\"))\n"
          # write create scheme criteria requirement statement
          seeds_file << text_line
          Rails.logger.info text_line
        end
        current_col_index += 1
      end while requirement_text.present?
      current_row_index += 1
    end

    seeds_file.close
  end
end