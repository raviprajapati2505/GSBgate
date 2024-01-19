#!/usr/bin/env bash
# Initialize rbenv and change to this scripts working directory, so rbenv picks up the .ruby-version
source /etc/profile.d/rbenv.sh
cd "$(dirname "$0")";

# run rake task
RAILS_ENV=production bundle exec rake gsb:clean_carrierwave_cache