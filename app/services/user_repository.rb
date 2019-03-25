class UserRepository
  def self.find_for_jwt_authentication(sub)
    User.find(sub)
  end
end