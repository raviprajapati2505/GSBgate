# ruby encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# Load the seed files
['generated', 'requirements', 'requirements_cm21issue3', 'generated_operations_2019', 'operations_requirements_2019' 'operations_2019', 'generated_design_and_build_2019', 'design_and_build_2019', 'all', 'generated_park_scheme_2019', 'update_park_scheme_2019', 'change_park_requirements_2019', 'update_operations_2019', 'generated_checklist_design_and_build', 'add_locations', 'energy_centers_checklist_2019', 'create_design_build_project_teams', 'change_titles', 'licences', Rails.env].each do |seed|
  seed_file = "#{Rails.root}/db/seeds/#{seed}.rb"
  if File.exists?(seed_file)
    puts "*** Loading #{seed} seed data"
    require seed_file
  end
end