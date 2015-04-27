class Role < ActiveRecord::Base
  has_many :users

  enum name: {admin: 'admin', certifier: 'certifier', registered: 'registered', anonymous: 'anonymous'}
end
