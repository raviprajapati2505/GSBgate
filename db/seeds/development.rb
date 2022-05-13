# System admins
User.create!(username: 'sas@vito.be', password: 'password', email: 'sas@vito.be', role: :system_admin, name: 'System admin')

# GSAS trust managers
User.create!(username: 'dr.esam@example.com', password: 'password', email: 'sas@vito.be', role: :gsas_trust_manager, name: 'Head of GSAS')

# GSAS trust top managers
User.create!(username: 'dr.youssef@example.com', password: 'password', email: 'sas@vito.be', role: :gsas_trust_top_manager, name: 'Chairman')

# GSAS trust admins
User.create!(username: 'omeima@example.com', password: 'password', email: 'sas@vito.be', role: :gsas_trust_admin, name: 'GSAS trust admin')

# GSAS trust
User.create!(username: 'bart.daniels@vito.be', password: 'password', email: 'bart.daniels@vito.be', role: :default_role, gord_employee: true, name: 'Bart Daniels')
User.create!(username: 'karel.styns@vito.be', password: 'password', email: 'karel.styns@vito.be', role: :default_role, gord_employee: true, name: 'Karel Styns')

# Project team
User.create!(username: 'koen.dierckx@vito.be', password: 'password', email: 'koen.dierckx@vito.be', role: :default_role, gord_employee: false, name: 'Koen Dierckx')
User.create!(username: 'kristof.dhalle@vito.be', password: 'password', email: 'kristof.dhalle@vito.be', role: :default_role, gord_employee: false, name: 'Kristof Dhallé')