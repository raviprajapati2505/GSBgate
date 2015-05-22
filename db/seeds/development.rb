# Add admin user
User.create!(email: 'admin@vito.be', password: 'gsas-secret', password_confirmation: 'gsas-secret', role: :system_admin)

User.create!(email: 'owner@example.com', password: 'password', password_confirmation: 'password', role: :project_owner)
User.create!(email: 'manager@example.com', password: 'password', password_confirmation: 'password', role: :project_team_member)
User.create!(email: 'read_write@example.com', password: 'password', password_confirmation: 'password', role: :project_team_member)
User.create!(email: 'read_only@example.com', password: 'password', password_confirmation: 'password', role: :project_team_member)
User.create!(email: 'no_member@example.com', password: 'password', password_confirmation: 'password', role: :project_team_member)

Project.create!(name: 'example project', owner: User.find_by_email('owner@example.com'), address: 'Boeretang 200', location: 'Mol', country: 'Belgium')

ProjectAuthorization.create!(user: User.find_by_email('manager@example.com'), project: Project.find_by_name('example project'), permission: :manage)
ProjectAuthorization.create!(user: User.find_by_email('read_write@example.com'), project: Project.find_by_name('example project'), permission: :read_and_write, category: Category.find_by_code('E'))
ProjectAuthorization.create!(user: User.find_by_email('read_only@example.com'), project: Project.find_by_name('example project'), permission: :read_only)