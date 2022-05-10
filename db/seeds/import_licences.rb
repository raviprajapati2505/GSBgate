require 'roo'

xlsx = Roo::Excelx.new("#{Rails.root}/db/imports/licence_allocation_sample.xlsx")
header = xlsx.row(2)

user_cgp_sheet = xlsx.sheet_for('Service Provider-CGPs')
user_licences_sheet = xlsx.sheet_for('CGPs')

xlsx.each_with_pagename do |name, sheet|

    if(name == 'ServiceProviders')
        sp_errors = []

        (4..xlsx.last_row).each do |i|
            row = Hash[[header, xlsx.row(i)].transpose]
            email = row["email"]&.squish&.strip&.downcase
            service_provider = User.find_or_initialize_by(email: email)
            service_provider.name ||= row["name"].to_s
            service_provider.username ||= row["username"].to_s
            service_provider.password = 'test#1234'
            service_provider.active = true
            service_provider.role = 'service_provider'
            service_provider.type = 'ServiceProvider'
            service_provider.skip_confirmation!

            unless service_provider.save
                sp_errors << "Row: #{i}, Email: #{service_provider.email}, Message: #{service_provider.errors.full_messages}"
            end
        end

        puts "--------------------------Service Provider Errors----------------------------"
        puts "Error Count #{sp_errors.size}"
        puts sp_errors.join("\n")
    end
    if(name == 'Service Provider-CGPs')
        cp_errors = []
        header_for_cgp = user_cgp_sheet.row(2)

        (4..user_cgp_sheet.last_row).each do |i|
            row_new = Hash[[header_for_cgp, user_cgp_sheet.row(i)].transpose]
            email = row_new["service_provider_email"]&.squish&.strip&.downcase
            service_provider = ServiceProvider.find_by(email: email)

            if service_provider.present?
                new_users = row_new["user_email"].split(',').map(&:squish).map(&:strip)

                new_users.each do |email|
                    user = User.find_or_initialize_by(email: email.downcase)
                    user.name ||= email
                    user.username ||= email
                    user.password = 'test#1234'
                    user.service_provider_id = service_provider.id
                    user.active = true
                    user.skip_confirmation!

                    unless user.save
                        # enable this if the case case of username already exists in database 
                        # user = User.find_by(username: email.downcase)
                        # user.service_provider_id = service_provider.id
                        # user.save
                        cp_errors << "Row: #{i}, Email: #{user.email}, Message: #{user.errors.full_messages}"
                    end
                end
            end
        end

        puts "\n\n\n"
        puts "--------------------------CP users Errors----------------------------"
        puts "Error Count #{cp_errors.size}"
        puts cp_errors.join("\n")
    end

    if(name == 'CGPs')
        cp_licences_errors = []
        header_for_licences = user_licences_sheet.row(5)
        (7..user_licences_sheet.last_row).each do |i|
            row_licence = Hash[[header_for_licences, user_licences_sheet.row(i)].transpose]
            user = User.find_by(email: row_licence["Email"]&.squish&.strip&.downcase)

            if user.present?
                type_of_licences.each do |type|
                    if row_licence[type].present? && row_licence[type].to_s.squish&.strip != '-'
                        formatted_date = row_licence[type].to_s
                        expiry_date = formatted_date.to_date
                        licence = Licence.find_by(title: type)

                        access_licence = user.access_licences.find_or_initialize_by(licence_id: licence&.id)
                        access_licence.expiry_date = expiry_date
                    end
                end

                unless user.save
                    cp_licences_errors << "Row: #{i}, Email: #{user.email}, Message: #{user.errors.full_messages}"
                end
            end
        end

        puts "\n\n\n"
        puts "--------------------------Licences Errors----------------------------"
        puts "Error Count #{cp_licences_errors.size}"
        puts cp_licences_errors.join("\n")
    end

    def type_of_licences
        ["TYPE 1", "TYPE 2", "TYPE 3", "TYPE 4", "TYPE 5", "TYPE 6", "GSAS CONSTRUCTION MANAGEMENT", "GSAS OPERATIONS", "TYPE 1 - CGP", "TYPE 2 - CGP","TYPE 3 - CGP", "GSAS CONSTRUCTION MANAGEMENT - CGP", "GSAS OPERATIONS - CGP", "TYPE 1 - CEP","GSAS CONSTRUCTION MANAGEMENT - CEP", "GSAS OPERATIONS - CEP"]
    end
end