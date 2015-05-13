class Scheme < ActiveRecord::Base
  belongs_to :certificate
  has_many :certification_paths
end
