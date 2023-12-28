# The Warden base strategy for GSAS
class BaseStrategy < ::Warden::Strategies::Base
  def valid?
    return false if request.get?
    user_data = params.fetch('user', {})
    !(user_data['username'].blank? || user_data['password'].blank?)
  end
end
