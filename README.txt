== Hardware requirements

The hardware requirements depend on the amount of users. But the following minimum setup is required:
1. Web server:
	- 4GB RAM
	- 2 CPUs
	- 40 GB HDD
2. Database server:
	- 1GB RAM
	- 1 CPUs
	- 40 GB HDD


== Software requirements

The minimum software requirements are:
1. Web server:
	- Linux Ubuntu 14.4 LTS
	- Apache 2 with Passenger
	- Ruby 2.2.2
2. Database server:
	- Linux Ubuntu 14.4 LTS
	- PostgreSQL 9.3
	- PostGIS 2.1.2


== How to set up this project

1. Create the following folder on the web server: '/var/gord-gsas'
2. Unpack the source code in this newly created folder.
3. Perform a 'bundle install' in the folder.
4. Copy 'config/database.example.yml' to 'config/database.yml'.
5. Enter your database credentials in 'config/database.yml'.
6. Update the SMTP settings in 'config/environments/production.rb'.
7. Perform a 'rake db:reset'.
8. Precompile the assets with 'rake assets:precompile'.
9. Create an Apache 'www.gsas.qa' vhost for the newly created folder.
10. Instal the SSL certificate for 'www.gsas.qa'.


== How to set up the cron jobs

The following rake tasks should be run once a day by a cron job:
1. gsas:destroy_old_empty_projects
2. gsas:send_digest_mail
3. gsas:create_duration_task
4. gsas:create_overdue_task
5. gsas:clean_up_expired_archives
6. gsas:generate_archives (should be run more frequently, e.g. every 15 minutes)

This can be done by running a shell script. For example:
	source /etc/profile.d/rbenv.sh
	cd /var/gord-gsas
	RAILS_ENV=production bundle exec rake gsas:send_digest_mail