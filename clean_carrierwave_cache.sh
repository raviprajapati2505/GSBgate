#!/usr/bin/env bash
source /etc/profile.d/rbenv.sh

RAILS_ENV=production bundle exec rake gsas:clean_carrierwave_cache