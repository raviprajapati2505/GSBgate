# GSASgate Rails application

## 1. Installation manual
Follow these steps to setup the application in the production environment.

### 1.1 Hardware requirements
The hardware requirements depend on the amount of users. But the following minimum setup is required:
1. Web server:
   * 4 GB RAM
   * 2 CPUs
   * 40 GB HDD
1. Database server:
   * 1 GB RAM
   * 1 CPUs
   * 40 GB HDD
1. File server:
   * 1 TB HDD

### 1.2 Software requirements
Although other solutions are possible, VITO uses the following setup:
1. Web server:
   * Linux Ubuntu 16.04 LTS
   * Apache 2.4 with the following modules:
      * actions
      * expires
      * headers
      * proxy
      * proxy_http
      * rewrite
      * ssl
      * xsendfile
   * Puma Ruby/Rack web server with Unix domain sockets
   * Ruby 2.5.1
   * rbenv
   * For the chart generation in PDF reports:
      * Node 6.17.1 with the pm2 package
      * Some extra required OS packages are listed here: https://github.com/Automattic/node-canvas
1. Database server:
   * Linux Ubuntu 16.04 LTS
   * PostgreSQL 10.8
   
### 1.3 Apache virtual host configuration
```
<VirtualHost *:80>
  ServerName www.gsas.qa
  ServerAdmin sas@vito.be

  ## Vhost docroot
  DocumentRoot "/var/www/gord/current/public"

  AllowEncodedSlashes off

  ## Directories, there should at least be a declaration for /var/www/gord/current/public

  <Directory "/var/www/gord/current/public">
    Options -MultiViews
    AllowOverride All
    Require all granted
  </Directory>

  <LocationMatch "^/(assets|packs|system|uploads|fonts|img|webfonts)/.*">
    Header unset ETag
    Require all granted
    ExpiresActive On
    ExpiresDefault "access plus 1 year"
    ProxyPass !
    FileETag None
  </LocationMatch>

  <LocationMatch "^/.(gif|jpe?g|png|txt|htm?l|docx|pdf)$">
    Header unset ETag
    Require all granted
    ExpiresActive On
    ExpiresDefault "access plus 1 year"
    ProxyPass !
    FileETag None
  </LocationMatch>

  ## Logging
  ErrorLog "/var/log/apache2/www.gsas.qa_error.log"
  ServerSignature Off
  CustomLog "/var/log/apache2/www.gsas.qa_healthcheck.log" "health" env=healthcheck
  CustomLog "/var/log/apache2/www.gsas.qa_access.log" "sas" env=!healthcheck

  ## Proxy rules
  ProxyRequests Off
  ProxyPreserveHost On
  ProxyAddHeaders On
  ProxyPass /robots.txt !
  ProxyPass /favicon.ico !
  ProxyPassMatch ^/(404|422|500).html$ !
  ProxyPass / unix:/run/sas-puma-gord.socket|http://www.gsas.qa/
  ProxyPassReverse / unix:/run/sas-puma-gord.socket|http://www.gsas.qa/
  ## Rewrite rules
  RewriteEngine On

  ## SetEnv/SetEnvIf for environment variables
  SetEnv SECRET_KEY_BASE [INSERT_KEY_HERE]
  SetEnv RAILS_ENV production
  SetEnv RAILS_SERVE_STATIC_FILES true
  SetEnv RECAPTCHA_PUBLIC_KEY [INSERT_KEY_HERE]
  SetEnv RECAPTCHA_PRIVATE_KEY [INSERT_KEY_HERE]

  ## Enable XSendFile
  XSendFile On
  XSendFilePath "/var/www/gord/shared/private"
</VirtualHost>
```

### 1.4 Set rbenv environment variables
* DATABASE_SERVER=db.local
* DATABASE_NAME=gord_production
* DATABASE_USERNAME=gord_production
* DATABASE_PASSWORD=secret
* HOST=www.gsas.qa
* PROTOCOL=https
* SECRET_KEY_BASE=yourkey
* RAILS_ENV=production
* RAILS_SERVE_STATIC_FILES=true
* RECAPTCHA_PUBLIC_KEY=yourkey
* RECAPTCHA_PRIVATE_KEY=yourkey
* SHARED_PATH=/var/www/gord/shared

### 1.5 Environment configuration
Review the setting in config/environments/production.rb (e.g. SMTP & linkme settings)

### 1.6 Configure server cron jobs
The following rake tasks should be run once a day by a cron job:
1. gsas:clean_carrierwave_cache
1. gsas:clean_up_expired_archives
1. gsas:create_duration_task
1. gsas:create_overdue_task
1. gsas:destroy_old_empty_projects
1. gsas:generate_archives (should be run more frequently, e.g. every 15 minutes)
1. gsas:send_digest_mail

This could be done using the shell scripts in the "sh" directory.

### 1.7 Mount private files
Mount the "private" directory on the file server.

### 1.8 Deployment
We highly recommend using Capistrano (with Git) as a deployment tool. For more info see:
* Gemfile
* Capfile
* config/deploy.rb
* config/deploy/*

## 2. Developer guidelines
Developers of the GSASgate project should follow these steps.

### 2.1 Integrated development environment
We highly recommend using the JetBrains IntelliJ or Rubymine IDE.

### 2.2 Git workflow
The Git workflow principle is used. Please read https://www.atlassian.com/git/tutorials/comparing-workflows/gitflow-workflow

Please respect the following branch policy:
* Master (=production): only merge from origin/staging branch or apply hot fixes
* Staging: only apply hot fixes or merge feature branches
* Feature branches: merge origin/staging before merging into staging branch
* Bug fix branches: merge origin/staging before merging into staging branch

### 2.3 Cross platform gems
When installing new gems using "bundle install", please ensure the gems work cross platform by running these commands before committing the lockfile:
* bundle lock --add-platform ruby
* bundle lock --add-platform x86_64-linux 
* bundle lock --add-platform x86-mingw32
