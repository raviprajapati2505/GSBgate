##############################################################################################################
#######################  SCRIPT TO RE-CREATE DB BEFORE NEW DEPLOYEMENT ON STAGING ENV. ######################
########################### WRITTEN BY VISHAL DIXIT ###############################
#####################UPDATED- 09/09/2020 #################
##############################################################################################################

WD="/var/www/gord_staging/current"
DD="/var/www/gord_staging/current/private/database_backup/"
DB_PASSWORD="`printenv DATABASE_PASSWORD`"
cd $WD
# For DB dump
RAILS_ENV=staging bundle exec rake db:db_dump_production
cd $DD
ls -lh;
# only to show example path
echo "/var/www/gord_staging/current/private/database_backup/"
cd $WD
# db backup file with path
echo -n "Enter DB Backup Filename(with path) > "
read db_backup_file
# stop puma service
sudo service sas-puma-gord_staging stop
# database drop
RAILS_ENV=staging bundle exec rake db:drop DISABLE_DATABASE_ENVIRONMENT_CHECK=1
# database create
RAILS_ENV=staging bundle exec rake db:create
echo "DB Password is $DB_PASSWORD"
# database restore from db backup file
pg_restore --verbose --clean --no-acl -U production -d gordprod  $db_backup_file
# start puma service
sudo service sas-puma-gord_staging restart
# information for user
echo "Process completed, replace user emails in ONLY STAGING enviroment, use given below commands"
echo "cd $WD"
echo "RAILS_ENV=staging bundle exec rails c"
echo 'User.all.update_all(email: "no-reply@gord.qa")'
