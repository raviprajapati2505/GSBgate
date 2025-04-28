# update ServiceProvider type to Corporate in users
ActiveRecord::Base.connection.execute "UPDATE users SET type = 'Corporate' WHERE type = 'ServiceProvider'"

# Update all ServiceProviderLicences to CorporateLicences
Licence.where(licence_type: "ServiceProviderLicence").find_each do |licence|
  licence.licence_type = "CorporateLicence"
  licence.display_name = licence.display_name.gsub!(/Service Provider/, "Corporate")
  licence.title = licence.title.gsub!(/Service Provider/, "Corporate")
  licence.description = licence.description.gsub!(/Service Provider/, "Corporate")
  licence.save
end

# rename audit log visibility
AuditLogVisibility.find_by(name:'GSB trust team internal').update(name: "GSB team internal")

# remove trust certification path statues

CertificationPathStatus.where("description LIKE ?", "%trust%").find_each do |status|
  updated_description = status.description.gsub(/\btrust\b/i, '').squeeze(' ').strip
  status.update!(description: updated_description)
end
