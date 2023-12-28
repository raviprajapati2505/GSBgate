class RequirementCategory < ApplicationRecord
  validates :title, :display_weight, presence: true, uniqueness: { case_sensitive: false }
  has_many :requirements, dependent: :nullify
end
