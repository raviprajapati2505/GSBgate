# Let Warden discover our strategies
Warden::Strategies.add(:local, LocalStrategy)
Warden::Strategies.add(:linkme, LinkmeStrategy)

# Tell Warden how to serialize users
Warden::Manager.serialize_into_session do |user|
  user.id
end

Warden::Manager.serialize_from_session do |id|
  User.find_by_id(id)
end

Warden::JWTAuth.configure do |config|
  config.secret = ENV['JWT_SECRET_KEY']
  config.expiration_time = 43200 # 12 hours
  config.mappings = { default: UserRepository }
  config.revocation_strategies = { default: RevocationStrategy }
  config.dispatch_requests = [
      ['POST', %r{^/api/sessions$}]
  ]
  config.revocation_requests = [
      ['DELETE', %r{^/api/sessions$}]
  ]
end

Warden::JWTAuth::Middleware

# Add warden as rack middleware
Rails.application.config.middleware.insert_after ActionDispatch::Flash, Warden::Manager do |manager|
  manager.default_strategies :jwt, :local, :linkme
  manager.failure_app = UnauthorizedController
end