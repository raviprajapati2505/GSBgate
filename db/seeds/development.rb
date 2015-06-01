# Add admin user
User.create!(email: 'admin@vito.be', password: 'gsas-secret', password_confirmation: 'gsas-secret', role: :system_admin)

User.create!(email: 'owner@example.com', password: 'password', password_confirmation: 'password', role: :project_team_member)
User.create!(email: 'manager@example.com', password: 'password', password_confirmation: 'password', role: :project_team_member)
User.create!(email: 'read_write@example.com', password: 'password', password_confirmation: 'password', role: :project_team_member)
User.create!(email: 'read_only@example.com', password: 'password', password_confirmation: 'password', role: :project_team_member)
User.create!(email: 'no_member@example.com', password: 'password', password_confirmation: 'password', role: :project_team_member)

Project.create!(name: 'Grand Hyatt Doha', owner: User.find_by_email('owner@example.com'), address: 'Grand Hyatt Doha, Box 24010', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.528132 25.377381)')
Project.create!(name: 'Al Jazeera International', owner: User.find_by_email('owner@example.com'), address: 'Al Jazeera, Wadi Al Sail West, PO Box 23127', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.498654 25.316083)')
Project.create!(name: 'Gulf Laboratory & X-Ray', owner: User.find_by_email('owner@example.com'), address: 'Gulf Laboratory & X-Ray, Al Kinana Street', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.501958 25.277719)')
Project.create!(name: 'Qatar Science & Technology Park (QSTP)', owner: User.find_by_email('owner@example.com'), address: 'Education City, Al Luqta St, Ar-Rayyān', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.437160 25.324565)')
Project.create!(name: 'Qatar University', owner: User.find_by_email('owner@example.com'), address: 'Qatar University, Al Tarfa', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.487169 25.377217)')
Project.create!(name: 'Site of Doha Convention Center and Tower', owner: User.find_by_email('owner@example.com'), address: 'Site of Doha Convention Center and Tower, Diplomatic Area', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.531711 25.323105)')

ProjectAuthorization.create!(user: User.find_by_email('manager@example.com'), project: Project.find_by_name('Grand Hyatt Doha'), permission: :manage)
ProjectAuthorization.create!(user: User.find_by_email('read_write@example.com'), project: Project.find_by_name('Grand Hyatt Doha'), permission: :read_and_write, category: Category.find_by_code('E'))
ProjectAuthorization.create!(user: User.find_by_email('read_only@example.com'), project: Project.find_by_name('Grand Hyatt Doha'), permission: :read_only)