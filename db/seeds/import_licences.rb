require 'roo'

xlsx = Roo::Excelx.new("#{Rails.root}/db/imports/licence_allocation_sample.xlsx")
header = xlsx.row(2)

user_cgp_sheet = xlsx.sheet_for('Service Provider-CGPs')
user_licences_sheet = xlsx.sheet_for('CGPs')

xlsx.each_with_pagename do |name, sheet|

    if(name == 'ServiceProviders')
        (4..xlsx.last_row).each do |i|
            row = Hash[[header, xlsx.row(4)].transpose]
            user_service_provider = User.find_or_initialize_by(email: row["email"])
            user_service_provider.name ||= row["name"].to_s
            user_service_provider.username ||= row["username"].to_s
            user_service_provider.password = 'test#1234'
            user_service_provider.active = true
            user_service_provider.role = 'service_provider'
            user_service_provider.type = 'ServiceProvider'
            user_service_provider.skip_confirmation!
            user_service_provider.save
        end
    end

    if(name == 'Service Provider-CGPs')
        header_for_cgp = user_cgp_sheet.row(2)
        (4..user_cgp_sheet.last_row).each do |i|
            row_new = Hash[[header_for_cgp, user_cgp_sheet.row(i)].transpose]
            service_provider_exists = ServiceProvider.find_by(email: row_new["service_provider_email"])
            if !service_provider_exists.nil?
                
                new_users = row_new["user_email"].split(',')
                new_users.each do |email|
                    user = User.find_or_initialize_by(email: email.downcase)
                    user.name ||= email
                    user.username ||= email
                    user.password = 'test#1234'
                    user.service_provider_id = service_provider_exists.id
                    user.active = true
                    #@user.role = 'service_provider'
                    user.skip_confirmation!
                    user.save
                end
            end
        end
    end

    if(name == 'CGPs')
        header_for_licences = user_licences_sheet.row(5)
        (7..user_licences_sheet.last_row).each do |index_licence|
            row_licence = Hash[[header_for_licences, user_licences_sheet.row(index_licence)].transpose]
            user_exists = User.find_by(email: row_licence["Email"].downcase)
            if !user_exists.nil?
                type_of_licences.each do |type|
                    if !row_licence[type].nil? && row_licence[type] != '-'
                        #puts type
                        d = row_licence[type].to_s
                        fulldate = d.to_date
                        licence_data = Licence.find_by(title: type)
                        if !licence_data.nil?
                            access_licences = AccessLicence.find_or_initialize_by(licence: licence_data, user: user_exists)
                            #puts access_licences.id
                            access_licences.user = user_exists
                            access_licences.licence = licence_data
                            access_licences.expiry_date = fulldate
                            access_licences.save
                        end
                    end
                end
            end    
        end
    end

    def type_of_licences
        ["TYPE 1", "TYPE 2", "TYPE 3", "TYPE 4", "TYPE 5", "TYPE 6", "GSAS CONSTRUCTION MANAGEMENT", "GSAS OPERATIONS", "TYPE 1 - CGP", "TYPE 2 - CGP","TYPE 3 - CGP", "GSAS CONSTRUCTION MANAGEMENT - CGP", "GSAS OPERATIONS - CGP", "TYPE 1 - CEP","GSAS CONSTRUCTION MANAGEMENT - CEP", "GSAS OPERATIONS - CEP"]
    end
end