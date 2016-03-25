# System admins
User.create!(username: 'sas@vito.be', password: 'password', email: 'sas@vito.be', linkme_user: false, role: :system_admin, first_name: 'System admin')

# GSAS trust managers
User.create!(username: 'dr.esam@example.com', password: 'password', email: 'sas@vito.be', linkme_user: false, role: :gsas_trust_manager, first_name: 'GSAS trust manager')

# GSAS trust top managers
User.create!(username: 'dr.youssef@example.com', password: 'password', email: 'sas@vito.be', linkme_user: false, role: :gsas_trust_top_manager, first_name: 'GSAS trust top manager')

# GSAS trust admins
User.create!(username: 'omeima@example.com', password: 'password', email: 'sas@vito.be', linkme_user: false, role: :gsas_trust_admin, first_name: 'GSAS trust admin')

# GSAS trust
User.create!(username: 'bart.daniels@vito.be', password: 'password', email: 'bart.daniels@vito.be', linkme_user: false, role: :default_role, cgp_license: true, gsas_trust_team: true, first_name: 'Bart', last_name: 'Daniels')
User.create!(username: 'karel.styns@vito.be', password: 'password', email: 'karel.styns@vito.be', linkme_user: false, role: :default_role, cgp_license: false, gsas_trust_team: true, first_name: 'Karel', last_name: 'Styns')

# Project team
User.create!(username: 'koen.dierckx@vito.be', password: 'password', email: 'koen.dierckx@vito.be', linkme_user: false, role: :default_role, cgp_license: true, gsas_trust_team: false, first_name: 'Koen', last_name: 'Dierckx')
User.create!(username: 'kristof.dhalle@vito.be', password: 'password', email: 'kristof.dhalle@vito.be', linkme_user: false, role: :default_role, cgp_license: false, gsas_trust_team: false, first_name: 'Kristof', last_name: 'Dhallé')