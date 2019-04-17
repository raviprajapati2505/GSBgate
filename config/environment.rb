# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

# Read current Git commit hash from Capistrano's REVISION file
APP_VERSION = IO.popen('cat REVISION').readlines[0].truncate(8, omission: '') rescue ''