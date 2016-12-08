#!/usr/bin/env bash
source /etc/profile.d/rbenv.sh
CUR_DIR="`dirname \"$0\"`"
cd "$CUR_DIR"

RAILS_ENV=production bundle exec rake gsas:create_duration_task
RAILS_ENV=production bundle exec rake gsas:create_overdue_task