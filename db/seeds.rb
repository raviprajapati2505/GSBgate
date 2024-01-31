# ruby encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# Load the seed files
[
  'locations', 
  'notification_types', 
  'building_type_group', 
  'certificates', 
  'development_types', 
  'certification_path_statuses',
  'owners',
  'schemes',
  'users', 
  Rails.env
].each do |seed|
  seed_file = "#{Rails.root}/db/seeds/#{seed}.rb"
  if File.exists?(seed_file)
    puts "*** Loading #{seed} seed data"
    require seed_file
  end
end