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

# Add warden as rack middleware
Rails.application.config.middleware.insert_after ActionDispatch::Flash, Warden::Manager do |manager|
  manager.default_strategies :local, :linkme
  manager.failure_app = UnauthorizedController
end

