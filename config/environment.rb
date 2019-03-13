# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

# Read current Git commit hash from Capistrano's REVISION file
APP_VERSION = IO.popen('cat REVISION').readlines[0] rescue ''
