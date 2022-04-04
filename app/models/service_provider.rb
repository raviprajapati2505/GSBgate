class ServiceProvider < User
  has_many :users, class_name: 'User', foreign_key: 'service_provider_id', dependent: :destroy
end
