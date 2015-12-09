# SYSTEM
create_confirmed_user('sas@vito.be', 'password', :system_admin)

#
# # Management
create_confirmed_user('dr.youssef@example.com', 'password', :gord_top_manager)
create_confirmed_user('dr.esam@example.com', 'password', :gord_manager)
#
# # Admins
create_confirmed_user('gsas@example.com', 'password', :gord_admin)

#
# # Certifiers
(1..100).each do |i|
  create_confirmed_user("certifier_#{i}@example.com", 'password', :certifier)
end

#
# # Enterprise clients
(1..100).each do |i|
  create_confirmed_user("enterprise_client_#{i}@example.com", 'password', :enterprise_client)
end

#
# # Assessors
create_confirmed_user('koen.dierckx@vito.be', 'password', :assessor)
create_confirmed_user('bart.daniels@vito.be', 'password', :assessor)
create_confirmed_user('kristof.dhalle@vito.be', 'password', :assessor)
(1..100).each do |i|
  create_confirmed_user("assessor_#{i}@example.com", 'password', :assessor)
end


# Project.create!(name: 'Grand Hyatt Doha', owner: User.find_by_email('owner@example.com'), address: 'Grand Hyatt Doha, Box 24010', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.528132 25.377381)', gross_area: 1, certified_area: 2, carpark_area: 3, project_site_area: 4, construction_year: 2015)
# Project.create!(name: 'Al Jazeera International', owner: User.find_by_email('owner@example.com'), address: 'Al Jazeera, Wadi Al Sail West, PO Box 23127', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.498654 25.316083)', gross_area: 1, certified_area: 2, carpark_area: 3, project_site_area: 4, construction_year: 2015)
# Project.create!(name: 'Gulf Laboratory & X-Ray', owner: User.find_by_email('owner@example.com'), address: 'Gulf Laboratory & X-Ray, Al Kinana Street', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.501958 25.277719)', gross_area: 1, certified_area: 2, carpark_area: 3, project_site_area: 4, construction_year: 2015)
# Project.create!(name: 'Qatar Science & Technology Park (QSTP)', owner: User.find_by_email('owner@example.com'), address: 'Education City, Al Luqta St, Ar-Rayy?n', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.437160 25.324565)', gross_area: 1, certified_area: 2, carpark_area: 3, project_site_area: 4, construction_year: 2015)
# Project.create!(name: 'Qatar University', owner: User.find_by_email('owner@example.com'), address: 'Qatar University, Al Tarfa', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.487169 25.377217)', gross_area: 1, certified_area: 2, carpark_area: 3, project_site_area: 4, construction_year: 2015)
# Project.create!(name: 'Site of Doha Convention Center and Tower', owner: User.find_by_email('owner@example.com'), address: 'Site of Doha Convention Center and Tower, Diplomatic Area', location: 'Doha', country: 'Qatar', latlng: 'POINT(51.531711 25.323105)', gross_area: 1, certified_area: 2, carpark_area: 3, project_site_area: 4, construction_year: 2015)

# ProjectsUser.create!(project: Project.find_by_name('Grand Hyatt Doha'), user: User.find_by_email('owner@example.com'), role: :project_manager)
# ProjectsUser.create!(project: Project.find_by_name('Al Jazeera International'), user: User.find_by_email('owner@example.com'), role: :project_manager)
# ProjectsUser.create!(project: Project.find_by_name('Gulf Laboratory & X-Ray'), user: User.find_by_email('owner@example.com'), role: :project_manager)
# ProjectsUser.create!(project: Project.find_by_name('Qatar Science & Technology Park (QSTP)'), user: User.find_by_email('owner@example.com'), role: :project_manager)
# ProjectsUser.create!(project: Project.find_by_name('Qatar University'), user: User.find_by_email('owner@example.com'), role: :project_manager)
# ProjectsUser.create!(project: Project.find_by_name('Site of Doha Convention Center and Tower'), user: User.find_by_email('owner@example.com'), role: :project_manager)
# ProjectsUser.create!(project: Project.find_by_name('Grand Hyatt Doha'), user: User.find_by_email('project_member_1@example.com'), role: :project_team_member)
# ProjectsUser.create!(project: Project.find_by_name('Grand Hyatt Doha'), user: User.find_by_email('project_manager@example.com'), role: :project_manager)
# ProjectsUser.create!(project: Project.find_by_name('Grand Hyatt Doha'), user: User.find_by_email('enterprise_client@example.com'), role: :enterprise_client)
# ProjectsUser.create!(project: Project.find_by_name('Grand Hyatt Doha'), user: User.find_by_email('certifier_manager@example.com'), role: :certifier_manager)