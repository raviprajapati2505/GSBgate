#!/usr/bin/env bash
source /etc/profile.d/rbenv.sh
MY_PATH="`dirname \"$0\"`"
cd "$MY_PATH"

RAILS_ENV=production bundle exec rake gsas:send_digest_mail