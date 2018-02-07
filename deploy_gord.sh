#!/usr/bin/env bash
# Initialize rbenv and change to this scripts working directory, so rbenv picks up the .ruby-version
source /etc/profile.d/rbenv.sh
cd "$(dirname "$0")";

# Deploy application
svn update --force
RAILS_ENV=production bundle install --path vendor/bundle
RAILS_ENV=production bundle exec rake assets:precompile
RAILS_ENV=production bundle exec rake db:migrate
sudo service apache2 restart