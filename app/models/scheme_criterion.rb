class SchemeCriterion < ActiveRecord::Base
  include Auditable

  belongs_to :scheme_category
  has_many :scheme_criterion_texts
  has_many :scheme_mix_criteria
  has_many :scheme_criteria_requirements
  has_many :requirements, through: :scheme_criteria_requirements
  serialize :scores

  before_save :handle_scores

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

  private

  def handle_scores
    unless self.scores.nil?
      new_scores = []
      self.scores.each do |score|
        unless score.is_a?(Array)
          unless score.empty?
            new_scores.push([score.to_i, score.to_f])
          end
        else
          new_scores.push(score)
        end
      end
      self.minimum_score = new_scores.first[1]
      self.maximum_score = new_scores.last[1]
      self.minimum_valid_score = self.minimum_score
      self.scores = YAML.load(new_scores.to_s)
    else
      self.minimum_score = 0.0
      self.maximum_score = self.weight
      self.minimum_valid_score = 0.0
    end
  end
end
