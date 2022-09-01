require 'roo'

def type_of_licences
    ["TYPE 1", "TYPE 2", "TYPE 3", "TYPE 4", "TYPE 5", "TYPE 6", "GSAS CONSTRUCTION MANAGEMENT", "GSAS OPERATIONS", "TYPE 1 - CGP", "TYPE 2 - CGP","TYPE 3 - CGP", "GSAS CONSTRUCTION MANAGEMENT - CGP", "GSAS OPERATIONS - CGP", "TYPE 1 - CEP","GSAS CONSTRUCTION MANAGEMENT - CEP", "GSAS OPERATIONS - CEP"]
end

def email_prefix(email = "")
    email_prefix = email.split("@")[0]
    return email_prefix.split('+')[0] || email_prefix
end

def save_member(row = nil, member)
    begin
        email_prefix = email_prefix(member.email)
        member.active = true
        member.password = email_prefix
        member.password_confirmation = email_prefix
        member.skip_confirmation!
        member.skip_send_user_licences_update_email = true

        return member.save(validate: false) ? nil : "Row: #{row}, Email: #{member.email}, Message: #{member.errors.full_messages}"
    rescue => e
        return "Row: #{row}, Email: #{member.email}, Message: #{e.message}"
    end
end

def print_errors(label, errors = [])
    puts "--------------------------#{label} Errors----------------------------"
    puts "Error Count #{errors&.compact&.size}"
    puts errors&.compact.join("\n")
end

# reset password for all users existing users.
User.all.each { |user| save_member(1, user) }

xlsx = Roo::Excelx.new("#{Rails.root}/db/imports/licence_allocation_sample.xlsx")
header = xlsx.row(1)

xlsx.each_with_pagename do |name, sheet|
    if(name == 'ServiceProviders')
        sp_errors = []

        (3..xlsx.last_row).each do |i|
            row = Hash[[header, xlsx.row(i)].transpose]
            email = row["email"]&.squish&.strip&.downcase

            service_provider = User.find_or_initialize_by(email: email)
            service_provider.name ||= row["name"].to_s
            service_provider.username ||= row["username"].to_s
            service_provider.role = 'service_provider'
            service_provider.type = 'ServiceProvider'

            # save record
            sp_errors << save_member(i, service_provider)
        end
        print_errors("Service Provider", sp_errors)
    end

    if(name == 'Service Provider-CGPs')
        cp_errors = []
        user_cgp_sheet = xlsx.sheet_for('Service Provider-CGPs')
        header_for_cgp = user_cgp_sheet.row(1)

        (3..user_cgp_sheet.last_row).each do |i|
            row_new = Hash[[header_for_cgp, user_cgp_sheet.row(i)].transpose]
            email = row_new["service_provider_email"]&.squish&.strip&.downcase
            service_provider = ServiceProvider.find_by(email: email)

            if service_provider.present?
                new_users = row_new["user_email"].split(',').map(&:squish).map(&:strip)
                new_user_usernames = row_new["user_name"].split(',').map(&:squish).map(&:strip)

                new_users.each_with_index  do |email, index|
                    useremail = email&.gsub('_x000d_ ', '')&.downcase
                    username = new_user_usernames[index]&.gsub('_x000d_ ', '')&.downcase
                    user = User.where('lower(email) = ? OR lower(username) = ?', useremail, username).first_or_initialize
                    
                    if user.new_record?
                        user.name = useremail
                        user.email = useremail
                        user.username = username
                    end
                    user.service_provider_id = service_provider.id

                    # save record
                    cp_errors << save_member(i, user)
                end
            end
        end
        
        puts "\n\n\n"
        print_errors("CP users", cp_errors)
    end

    # if(name == 'CGPs')
    #     cp_licences_errors = []
    #     user_licences_sheet = xlsx.sheet_for('CGPs')
    #     header_for_licences = user_licences_sheet.row(3)

    #     (5..user_licences_sheet.last_row).each do |i|
    #         row_licence = Hash[[header_for_licences, user_licences_sheet.row(i)].transpose]
    #         #user = User.find_by(email: row_licence["Email"]&.squish&.strip&.downcase)

    #         user_email = row_licence["Email"]&.gsub('_x000d_ ', '')&.squish&.strip&.downcase
    #         user_name = row_licence["Username"]&.gsub('_x000d_ ', '')&.squish&.strip&.downcase
    #         user = User.where('lower(email) = ? OR lower(username) = ?', user_email, user_name).first_or_initialize

    #         if user.present?
    #             type_of_licences.each do |type|
    #                 if row_licence[type].present? && row_licence[type].to_s.squish&.strip != '-'
    #                     formatted_date = row_licence[type].to_s
    #                     expiry_date = formatted_date.to_date + 2000.years
    #                     licence = Licence.find_by(title: type)
    #                     access_licence = user.access_licences.find_or_initialize_by(licence_id: licence&.id)
    #                     access_licence.expiry_date = expiry_date
    #                 end
    #             end
    #             # save record
    #             cp_licences_errors << save_member(i, user)
    #         end
    #     end

    #     puts "\n\n\n"
    #     print_errors("Licences", cp_licences_errors)
    # end
end

# create Users Admin
user = User.find_or_initialize_by(email: "users_admin@gord.qa")
user.name = "Users Admin"
user.username = "users_admin"
user.role = "users_admin"
save_member(1, user)

# Exceptional cases for users who were service providers.
emails = 
    ["mmoustafa27@hotmail.com",
    "aalhajri@qf.org.qa",
    "lamya@trustmgm.com",
    "sonny@montrealco.com",
    "venkat@galfarqatar.com.qa",
    "farah.othmani@arcadis.com"]
User.where(email: emails).each do |user|
    user.update_columns(role: "default_role", type: "User")
end

# Set GORD employees attribute to true.
usernames_for_gord_employee = 
    ["huss85",
    "n.alware@gord.qa",
    "m.alhumaiqani@gord.qa",
    "ydolem12",
    "alhorr@gord.qa",
    "farah123",
    "m.zaki@gord.qa",
    "mnajjar",
    "e.eliskandarani@gord.qa",
    "ialjundi",
    "c.espino@gord.qa",
    "a.khan@gord.qa",
    "aagonzales",
    "krajhansa",
    "salim",
    "driss",
    "info@gord.qa",
    "academy@gord.qa",
    "k.minnullah@gord.qa",
    "rubenmunoz",
    "r.alqawasmeh@gord.qa",
    "s.raji@gord.qa",
    "r.aadhil@hotmail.com",
    "f.azami@gord.qa",
    "m.rafi@gord.qa",
    "nizam.ph@gmail.com",
    "k.bhardwaj@gord.qa",
    "anjum_admin",
    "jajatuazon",
    "mdyusuff",
    "f.zahra@gord.qa",
    ".chaliulina@gord.qa",
    "syedhabeeb23",
    "o.abdalla@gord.qa",
    "a.elhoweris@gord.qa",
    "j.mwanda@gord.qa",
    "m.danish@gord.qa",
    "s.balan@gord.qa",
    "m.rizwan@gord.qa",
    "AnjumCGP",
    "abdulaleem001"]

User.where(username: usernames_for_gord_employee).each do |user|
    user.update_column(:gord_employee, true)
end

# delete all the tasks of activate user as we are importing and activating automaically
Task.where(task_description_id: Taskable::ACTIVATE_USER).destroy_all
