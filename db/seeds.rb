# ruby encoding: utf-8
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#

# Convenience function to seed users so we can skip confirmation
def create_confirmed_user(email, password, role)
  user = User.new(email: email, password: password, password_confirmation: password, role: role)
  user.skip_confirmation!
  user.save!
end

# Load the seed files
['generated', 'all', Rails.env].each do |seed|
  seed_file = "#{Rails.root}/db/seeds/#{seed}.rb"
  if File.exists?(seed_file)
    puts "*** Loading #{seed} seed data"
    require seed_file
  end
end