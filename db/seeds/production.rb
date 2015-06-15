# Add admin user
User.create!(email: 'sas@vito.be', password: 'password', password_confirmation: 'password', role: :system_admin)
User.create!(email: 'e.elsarrag@gord.qa', password: 'password', password_confirmation: 'password', role: :system_admin)

User.create!(email: 'owner@example.com', password: 'password', password_confirmation: 'password', role: :user)
User.create!(email: 'project_member_1@example.com', password: 'password', password_confirmation: 'password', role: :user)
User.create!(email: 'project_member_2@example.com', password: 'password', password_confirmation: 'password', role: :user)
User.create!(email: 'project_manager@example.com', password: 'password', password_confirmation: 'password', role: :user)
User.create!(email: 'enterprise_client@example.com', password: 'password', password_confirmation: 'password', role: :user)
User.create!(email: 'project_admin@example.com', password: 'password', password_confirmation: 'password', role: :user)

Project.create!(name: 'Grand Hyatt Doha', owner: User.find_by_email('owner@example.com'), address: 'Grand Hyatt Doha, Box 24010', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.528132 25.377381)')
Project.create!(name: 'Al Jazeera International', owner: User.find_by_email('owner@example.com'), address: 'Al Jazeera, Wadi Al Sail West, PO Box 23127', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.498654 25.316083)')
Project.create!(name: 'Gulf Laboratory & X-Ray', owner: User.find_by_email('owner@example.com'), address: 'Gulf Laboratory & X-Ray, Al Kinana Street', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.501958 25.277719)')
Project.create!(name: 'Qatar Science & Technology Park (QSTP)', owner: User.find_by_email('owner@example.com'), address: 'Education City, Al Luqta St, Ar-Rayy?n', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.437160 25.324565)')
Project.create!(name: 'Qatar University', owner: User.find_by_email('owner@example.com'), address: 'Qatar University, Al Tarfa', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.487169 25.377217)')
Project.create!(name: 'Site of Doha Convention Center and Tower', owner: User.find_by_email('owner@example.com'), address: 'Site of Doha Convention Center and Tower, Diplomatic Area', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.531711 25.323105)')

ProjectAuthorization.create!(project: Project.find_by_name('Grand Hyatt Doha'), user: User.find_by_email('project_member_1@example.com'), role: :project_team_member)
ProjectAuthorization.create!(project: Project.find_by_name('Grand Hyatt Doha'), user: User.find_by_email('project_manager@example.com'), role: :cgp_project_manager)
ProjectAuthorization.create!(project: Project.find_by_name('Grand Hyatt Doha'), user: User.find_by_email('enterprise_client@example.com'), role: :enterprise_account)
ProjectAuthorization.create!(project: Project.find_by_name('Grand Hyatt Doha'), user: User.find_by_email('project_admin@example.com'), role: :project_system_administrator)