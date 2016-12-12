#!/usr/bin/env bash
# Initialize rbenv and change to this scripts working directory, so rbenv picks up the .ruby-version
source /etc/profile.d/rbenv.sh
cd "$(dirname "$0")";

# run rake task
read -p "Are you sure? " -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    # do dangerous stuff
    RAILS_ENV=production bundle exec rake db:reset
fi
