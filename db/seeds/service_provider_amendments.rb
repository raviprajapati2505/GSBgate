require 'roo'

def save_service_provider(row = nil, service_provider)
	begin
			return service_provider.save(validate: false) ? nil : "Row: #{row}, Project Code: #{service_provider.code}, Message: #{service_provider.errors.full_messages}"
	rescue => e
			return "Row: #{row}, Project Code: #{service_provider.code}, Message: #{e.message}"
	end
end

def print_errors(label, errors = [])
	puts "--------------------------#{label} Errors----------------------------"
	puts "Error Count #{errors&.compact&.size}"
	puts errors&.compact.join("\n")
end

xlsx = Roo::Excelx.new("#{Rails.root}/db/imports/service_provider_amendments.xlsx")
header = xlsx.row(1)

sp_errors = []
(2..xlsx.last_row).each do |i|
	
    row = Hash[[header, xlsx.row(i)].transpose]

    find_service_provider = row["Project Service Provider Old"]&.squish&.strip
    new_service_provider_name = row["Project Service Provider"]&.squish&.strip

    project = Project.find_by(service_provider: find_service_provider)

    if project.present?
		project.service_provider = new_service_provider_name
		puts project.id

		# save record
		sp_errors << save_service_provider(i, project)
    end
end
print_errors("Service Provider", sp_errors)