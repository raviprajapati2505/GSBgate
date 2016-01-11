class SchemeCriterion < ActiveRecord::Base
  include Auditable

  belongs_to :scheme_category
  has_many :scheme_criterion_texts
  has_many :scheme_mix_criteria
  has_many :scheme_criteria_requirements
  has_many :requirements, through: :scheme_criteria_requirements
  serialize :scores

  scope :for_category, ->(category) {
    where(scheme_category_id: category.id)
  }

  def code
    "#{self.scheme_category.code}.#{self.number}"
  end

  def full_name
    "#{self.code}: #{self.name}"
  end

  # default_scope {
  #   joins(:criterion)
  #   .order('criteria.name')
  # }
end
