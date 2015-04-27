# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Add roles
Role.names.keys.each do |role|
  Role.find_or_create_by({name: role})
end

# Add admin user
User.create!(email: 'admin@vito.be', password: 'gsas-secret', password_confirmation: 'gsas-secret', role: Role.find_by_name(Role.names[:admin]))