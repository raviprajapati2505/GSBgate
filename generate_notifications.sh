#!/usr/bin/env bash
source /etc/profile.d/rbenv.sh

RAILS_ENV=production bundle exec rake gsas:send_digest_mail
exit