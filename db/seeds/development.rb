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
