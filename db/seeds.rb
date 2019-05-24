# ruby encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# Load the seed files
# ['generated', 'requirements', 'requirements_cm21issue3', 'generated_operations_2019', 'all', Rails.env].each do |seed|
#   seed_file = "#{Rails.root}/db/seeds/#{seed}.rb"
#   if File.exists?(seed_file)
#     puts "*** Loading #{seed} seed data"
#     require seed_file
#   end
# end
require "#{Rails.root}/db/seeds/generated_operations_2019.rb"