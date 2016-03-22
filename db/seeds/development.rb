# System admins
User.create!(username: 'sas@vito.be', password: 'password', email: 'sas@vito.be', linkme_user: false, role: :system_admin)

# GSAS trust managers
User.create!(username: 'dr.esam@example.com', password: 'password', email: 'sas@vito.be', linkme_user: false, role: :gord_manager)

# GSAS trust top managers
User.create!(username: 'dr.youssef@example.com', password: 'password', email: 'sas@vito.be', linkme_user: false, role: :gord_top_manager)

# GSAS trust admins
User.create!(username: 'omeima@example.com', password: 'password', email: 'sas@vito.be', linkme_user: false, role: :gord_admin)

# GSAS trust
User.create!(username: 'bart.daniels@vito.be', password: 'password', email: 'bart.daniels@vito.be', linkme_user: false, role: :certifier)
User.create!(username: 'karel.styns@vito.be', password: 'password', email: 'karel.styns@vito.be', linkme_user: false, role: :certifier)

# Project team
User.create!(username: 'koen.dierckx@vito.be', password: 'password', email: 'koen.dierckx@vito.be', linkme_user: false, role: :assessor)
User.create!(username: 'kristof.dhalle@vito.be', password: 'password', email: 'kristof.dhalle@vito.be', linkme_user: false, role: :assessor)