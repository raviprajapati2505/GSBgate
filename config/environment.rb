# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

APP_VERSION = IO.popen('svnversion').readlines[0] rescue ''