# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'criterion', 'criteria'
  inflect.irregular 'datum', 'data'
end

APP_VERSION = IO.popen('svnversion').readlines[0] rescue ''