require 'roo'

def type_of_licences
  ["TYPE 1", "TYPE 2", "TYPE 3", "TYPE 4", "TYPE 5", "TYPE 6", "GSAS CONSTRUCTION MANAGEMENT", "GSAS OPERATIONS", "TYPE 1 - CGP", "TYPE 2 - CGP","TYPE 3 - CGP", "GSAS CONSTRUCTION MANAGEMENT - CGP", "GSAS OPERATIONS - CGP", "TYPE 1 - CEP","GSAS CONSTRUCTION MANAGEMENT - CEP", "GSAS OPERATIONS - CEP"]
end

# as we have import new licences so removing all previous licences as necessary
AccessLicence.destroy_all

def email_prefix(email = "")
  email_prefix = email.split("@")[0]
  return email_prefix.split('+')[0] || email_prefix
end

def save_member(row = nil, member)
  begin
      email_prefix = email_prefix(member.email)
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

xlsx = Roo::Excelx.new("#{Rails.root}/db/imports/licence_user_allocation.xlsx")
header = xlsx.row(1)

xlsx.each_with_pagename do |name, sheet|
  if(name == 'Service Providers (full)')
    sp_errors = []
    sp_sheet = xlsx.sheet_for('Service Providers (full)')
    header_for_sp = sp_sheet.row(1)

    (2..sp_sheet.last_row).each do |i|
      row = Hash[[header_for_sp, sp_sheet.row(i)].transpose]
      email = row["Email"]&.squish&.strip&.downcase

      service_provider = User.find_or_initialize_by(email: email)
      service_provider.name ||= row["Name"].to_s
      service_provider.username ||= row["Username"].to_s
      service_provider.role = 'service_provider'
      service_provider.type = 'ServiceProvider'
      service_provider.active = true

      type_of_licences.each do |type|
        if row[type].present?
            if row[type] == 'YES'
              formatted_date = row['GSAS-D&B License Expiry'].to_s
              expiry_date = formatted_date.to_date
            else
              formatted_date = row[type].to_s
              expiry_date = formatted_date.to_date
            end
            licence = Licence.find_by(title: type)
            access_licence = service_provider.access_licences.find_or_initialize_by(licence_id: licence&.id)
            access_licence.expiry_date = expiry_date
          end
      end

      # save record
      sp_errors << save_member(i, service_provider)
    end
    print_errors("Service Provider", sp_errors)
  end

  if(name == 'GORD Staff')
    gord_staff_errors = []
    gord_staff_sheet = xlsx.sheet_for('GORD Staff')
    header_for_gord_staff = gord_staff_sheet.row(1)

    (2..gord_staff_sheet.last_row).each do |i|
      row = Hash[[header_for_gord_staff, gord_staff_sheet.row(i)].transpose]
      email = row["Email"]&.squish&.strip&.downcase

      user = User.find_or_initialize_by(email: email)
      if user.new_record?
        user.name = row["Name"].to_s
        user.username = row["Username"].to_s
        user.email = email
      end

      if row["User Role"] == 'Certification Manager'
        user.role = 'certification_manager'
      elsif row["User Role"] == 'Credentials Admin'
        user.role = 'credentials_admin'
      elsif row["User Role"] == 'Director GSAS Trust'
        user.role = 'gsas_trust_manager'
      elsif row["User Role"] == 'Document Controller'
        user.role = 'document_controller'
      elsif row["User Role"] == 'GORD Chairman'
        user.role = 'gsas_trust_top_manager'
      elsif row["User Role"] == 'GSAS Trust Admin'
        user.role = 'gsas_trust_admin'
      elsif row["User Role"] == 'GSBgate Admin'
        user.role = 'gsas_trust_admin'
      elsif row["User Role"] == 'Record Checker'
        user.role = 'record_checker'
      end

      if row['Account Status'] == 'Suspended' || row['Account Status'] == 'X' || row['Account Status'] == ''
        user.active = false
      else
        user.active = true
      end
      
      user.gord_employee = true
      user.practitioner_accreditation_type = row["Practitioner Accreditation Type"]&.squish&.strip&.downcase

      # save record
      gord_staff_errors << save_member(i, user)
    end
    
    puts "\n\n\n"
    print_errors("GORD Staff", gord_staff_errors)
  end

  if(name == 'Practitioners (full)')
    practitioners_errors = []
    practitioners_sheet = xlsx.sheet_for('Practitioners (full)')
    header_for_practitioner = practitioners_sheet.row(1)

    (2..practitioners_sheet.last_row).each do |i|
      row = Hash[[header_for_practitioner, practitioners_sheet.row(i)].transpose]

      user_email = row["Email"]&.gsub('_x000d_ ', '')&.squish&.strip&.downcase
      user_name = row["Username"]&.gsub('_x000d_ ', '')&.squish&.strip&.downcase
      user = User.where('lower(email) = ? OR lower(username) = ?', user_email, user_name).first_or_initialize

      if user.present?
        if user.new_record?
          user.name = row["Name"].to_s
          user.email = user_email
          user.username = user_name
        end
        user.gsas_id = row['GSAS ID']

        type_of_licences.each do |type|
          if row[type].present?
            formatted_date = row[type].to_s
            expiry_date = formatted_date.to_date
            licence = Licence.find_by(title: type)
            access_licence = user.access_licences.find_or_initialize_by(licence_id: licence&.id)
            access_licence.expiry_date = expiry_date
          end
        end

        service_provider_name = row["Service Provider"]&.squish&.strip
        service_provider = ServiceProvider.find_by(name: service_provider_name)
        if service_provider.present?
          user.service_provider_id = service_provider.id
        end

        if row['Account Status'] == 'In-Active' || row['Account Status'] == 'X'
          user.active = false
        else
          user.active = true
        end

        user.practitioner_accreditation_type = row["Practitioner Accreditation Type"]&.squish&.strip&.downcase

        # save record
        practitioners_errors << save_member(i, user)
      end
    end
  
    puts "\n\n\n"
    print_errors("Practitioners (full)", practitioners_errors)
  end
end

# delete all the tasks of activate user as we are importing and activating automaically
Task.where(task_description_id: Taskable::ACTIVATE_USER).destroy_all