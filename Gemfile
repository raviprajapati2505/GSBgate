source 'http://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2'

# Use postgresql as the database for Active Record
gem 'pg', '~> 0.21'

# Use SCSS for stylesheets
gem 'sass-rails'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# Puma service
gem 'puma'

# Use CoffeeScript for .coffee assets and views
# gem 'coffee-rails', '~> 4.1.0'
# gem 'coffee-script-source', '1.8.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
gem 'execjs'
# group :production do
#   gem 'therubyracer'
# end

# Use jquery as the JavaScript library
# gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.6.4'

# bundle exec rake doc:rails generates the API under doc/api.
# gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# used by the xlsx2seed rake task
gem 'roo'

group :development, :test do
  # replaces standard error page (stack trace, variable inspection, source code)
  gem 'better_errors'
  # -- add REPL and local instance variable inspection to better_errors
  gem 'binding_of_caller'
  # gem 'axlsx', '~> 2.0.1'
  # gem 'axlsx_rails', '~> 0.5.1'
end

group :development do
  # Deployment
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-npm'
  gem 'capistrano-rails'
  gem 'capistrano-rbenv'
  gem 'capistrano-systemd'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :x64_mingw]

# Rack middleware that provides authentication for rack applications
gem 'warden'

# Simple authorization solution
gem 'cancancan'

# rails-assets needs Bundler >= 1.8.4
gem 'bundler'

# Rails form builder
# For documentation, go to https://github.com/bootstrap-ruby/rails-bootstrap-forms#usage
gem 'bootstrap_form'

# Simplified file uploading
gem 'carrierwave'

# Pagination for resultsets
gem 'kaminari'

# Selection box
gem 'select2-rails', '< 4.0.0'

# Path helpers for javascript
gem 'js-routes'

# Read/write zip files
gem 'rubyzip'

# URI.encode / URI.escape is deprecated
gem 'addressable'

# Makes http fun again!
gem 'httparty'

# https://github.com/galetahub/ckeditor
gem 'ckeditor'

# Datatables.net, with server-side searching, sorting and filtering
gem 'effective_datatables' , '<= 2.4.6'

# PDF Generator
gem 'pdf-core'
gem 'prawn'
gem 'prawn-table'

# HTML, XML, SAX, and Reader parser.
gem 'nokogiri', '~> 1.10.1'

gem 'rails-dom-testing', '~> 1.0.9'

gem 'html2haml', '~> 2.2.0'

gem 'sprockets', '< 4.0.0'

# Required for password encryption
gem 'bcrypt'

# Font awesome
gem 'font-awesome-rails'

# JWT
gem 'warden-jwt_auth', '~> 0.3.5'

# Rails-Assets: access bower packages from our gem file
#  e.g. gem 'rails-assets-BOWER_PACKAGE_NAME'
#  do not forget to:
#   'require' them in application.js for javascript files
#   @import them in style.scss for (s)css files
source 'http://rails-assets.org' do
  gem 'rails-assets-animate.css'
  gem 'rails-assets-bootstrap'
  gem 'rails-assets-bootstrap-datepicker'
  gem 'rails-assets-bootstrap-timepicker'
  gem 'rails-assets-d3'
  gem 'rails-assets-d3-tip'
  gem 'rails-assets-dropzone'
  gem 'rails-assets-icheck'
  gem 'rails-assets-jquery'
  gem 'rails-assets-jquery-ujs'
  gem 'rails-assets-leaflet'
  gem 'rails-assets-metisMenu'
  gem 'rails-assets-pace'
  gem 'rails-assets-slimScroll'
  gem 'rails-assets-toastr'
  gem 'rails-assets-voidberg--html5sortable'
  gem 'rails-assets-three.js'
  gem 'rails-assets-leaflet-draw'
  gem 'rails-assets-proj4'
end