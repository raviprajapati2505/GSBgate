require 'roo'

def save_project(row = nil, project)
	begin
			return project.save(validate: false) ? nil : "Row: #{row}, Project Code: #{project.code}, Message: #{project.errors.full_messages}"
	rescue => e
			return "Row: #{row}, Project Code: #{project.code}, Message: #{e.message}"
	end
end

def print_errors(label, errors = [])
	puts "--------------------------#{label} Errors----------------------------"
	puts "Error Count #{errors&.compact&.size}"
	puts errors&.compact.join("\n")
end

xlsx = Roo::Excelx.new("#{Rails.root}/db/imports/project_amendments.xlsx")
header = xlsx.row(1)

project_errors = []
(2..xlsx.last_row).each do |i|
	
    row = Hash[[header, xlsx.row(i)].transpose]
		
    id = row["Project ID"]&.squish&.strip
    city = row["Project City"]&.squish&.strip
    district = row["Project District"]&.squish&.strip
    owner = row["Project Owner"]&.squish&.strip
    developer = row["Project Developer"]&.squish&.strip
    owner_business_sector = row["Project Owner Business Sector"]&.squish&.strip&.downcase
    developer_business_sector = row["Project Developer Business Sector"]&.squish&.strip&.downcase
    project = Project.find_by(code: id)

    if project.present?
		project.city = city
		project.district = district
		project.developer = developer
		project.owner = owner
		project.project_owner_business_sector = owner_business_sector
		project.project_developer_business_sector = developer_business_sector

		# save record
		project_errors << save_project(i, project)
    end
end
print_errors("Service Provider", project_errors)