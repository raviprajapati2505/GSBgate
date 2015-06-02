class Document < ActiveRecord::Base
  has_many :requirements, as: :reportable
  has_many :document_data
end
