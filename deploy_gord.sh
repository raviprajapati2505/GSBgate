#!/usr/bin/env bash
source /etc/profile.d/rbenv.sh
CUR_DIR="`dirname \"$0\"`"
cd "$CUR_DIR"

svn update --force

RAILS_ENV=production bundle install --path vendor/bundle
RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rake db:migrate

sudo service apache2 restart