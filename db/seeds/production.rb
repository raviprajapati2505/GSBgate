# Add admin user
User.create!(email: 'sas@vito.be', password: 'password', password_confirmation: 'password', role: :system_admin)