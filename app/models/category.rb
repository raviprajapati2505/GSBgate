class Category < ActiveResource
  has_many :criteria

  default_scope { order(name: :asc) }
end
