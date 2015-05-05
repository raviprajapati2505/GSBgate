# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Add admin user
User.create!(email: 'admin@vito.be', password: 'gsas-secret', password_confirmation: 'gsas-secret', role: :admin)

ProjectStatus.create!(name: 'Certification in review')
ProjectStatus.create!(name: 'GSAS certified')
ProjectStatus.create!(name: 'Preliminary stage pending')
ProjectStatus.create!(name: 'Suspended')