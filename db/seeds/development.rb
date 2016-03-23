# System admins
User.create!(username: 'sas@vito.be', password: 'password', email: 'sas@vito.be', linkme_user: false, role: :system_admin)

# GSAS trust managers
User.create!(username: 'dr.esam@example.com', password: 'password', email: 'sas@vito.be', linkme_user: false, role: :gsas_trust_manager)

# GSAS trust top managers
User.create!(username: 'dr.youssef@example.com', password: 'password', email: 'sas@vito.be', linkme_user: false, role: :gsas_trust_top_manager)

# GSAS trust admins
User.create!(username: 'omeima@example.com', password: 'password', email: 'sas@vito.be', linkme_user: false, role: :gsas_trust_admin)

# GSAS trust
User.create!(username: 'bart.daniels@vito.be', password: 'password', email: 'bart.daniels@vito.be', linkme_user: false, role: :default_role, cgp_license: true, gsas_trust_team: true)
User.create!(username: 'karel.styns@vito.be', password: 'password', email: 'karel.styns@vito.be', linkme_user: false, role: :default_role, cgp_license: false, gsas_trust_team: true)

# Project team
User.create!(username: 'koen.dierckx@vito.be', password: 'password', email: 'koen.dierckx@vito.be', linkme_user: false, role: :default_role, cgp_license: true, gsas_trust_team: false)
User.create!(username: 'kristof.dhalle@vito.be', password: 'password', email: 'kristof.dhalle@vito.be', linkme_user: false, role: :default_role, cgp_license: false, gsas_trust_team: false)