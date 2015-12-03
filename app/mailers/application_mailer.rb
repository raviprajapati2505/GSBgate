class ApplicationMailer < ActionMailer::Base
  default from: 'no-reply@gord.qa'
  layout 'mailer'
end