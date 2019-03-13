# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Use current Git commit hash as app version
APP_VERSION = IO.popen('git rev-parse HEAD').readlines[0] rescue ''