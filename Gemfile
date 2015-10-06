source 'http://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~>4.2'

# Use postgresql as the database for Active Record
gem 'pg'
gem 'activerecord-postgis-adapter', '~>3.0.0'
gem 'rgeo', '0.3.20'
gem 'ffi-geos'

# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'

# Use Twitter Bootstrap
# gem 'bootstrap-sass', '~> 3.3.4.1'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'

# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# See https://github.com/rails/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
# gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'

# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: [:mingw, :mswin, :jruby]

gem 'coffee-script-source', '1.8.0'

# Flexible authentication solution
gem 'devise'

# Simple authorization solution
gem 'cancancan', '~> 1.10.1'

# rails-assets needs Bundler >= 1.8.4
gem 'bundler', '>= 1.8.4'

# Rails form builder
# For documentation, go to https://github.com/bootstrap-ruby/rails-bootstrap-forms#usage
gem 'bootstrap_form'

# Simplified file uploading
gem 'carrierwave', github: 'carrierwaveuploader/carrierwave'

# File icons
gem 'rails-file-icons', github: 'sodalis/rails-file-icons' # Latest version is only available on github

# Pagination for resultsets
gem 'will_paginate-bootstrap', '~> 1.0.1'

# Selection box
gem 'select2-rails', '~> 3.5.9.3'

# Path helpers for javascript
gem 'js-routes', '~> 1.0.1'

# Read/write zip files
gem 'rubyzip', '~> 1.1.7'

# URI.encode / URI.escape is deprecated
gem 'addressable'

# https://github.com/galetahub/ckeditor
gem 'ckeditor', '~> 4.1.3'

# PDF Generator
gem 'prawn'

# Rails-Assets: access bower packages from our gem file
#  e.g. gem 'rails-assets-BOWER_PACKAGE_NAME'
#  do not forget to:
#   'require' them in application.js for javascript files
#   @import them in style.scss for (s)css files
source 'https://rails-assets.org' do
  gem 'rails-assets-animate.css'
  gem 'rails-assets-bootstrap'
  gem 'rails-assets-bootstrap-datepicker'
  gem 'rails-assets-d3'
  gem 'rails-assets-d3-tip'
  gem 'rails-assets-datatables'
  gem 'rails-assets-datatables-plugins'
  gem 'rails-assets-datatables-responsive'
  gem 'rails-assets-datatables-tabletools'
  gem 'rails-assets-dropzone'
  gem 'rails-assets-fontawesome'
  gem 'rails-assets-icheck'
  gem 'rails-assets-jquery'
  gem 'rails-assets-jquery-ujs'
  gem 'rails-assets-jquery.steps'
  gem 'rails-assets-metisMenu'
  gem 'rails-assets-pace'
  gem 'rails-assets-slimScroll'
  gem 'rails-assets-toastr'
  gem 'rails-assets-voidberg--html5sortable'
end


group :production do
  gem 'execjs'
  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  gem 'therubyracer'
end
