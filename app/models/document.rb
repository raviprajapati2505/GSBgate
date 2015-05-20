class Document < ActiveRecord::Base
  has_many :requirements, as: :reportable
end
