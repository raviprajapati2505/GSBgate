class Category < ActiveRecord::Base
  has_many :criteria

  default_scope { order(name: :asc) }
end
