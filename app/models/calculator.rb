class Calculator < ActiveRecord::Base
  has_many :requirements, as: :reportable
end