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
