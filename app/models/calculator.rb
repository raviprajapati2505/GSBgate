class Calculator < ActiveRecord::Base
  has_many :requirements, as: :reportable
  has_many :fields
end