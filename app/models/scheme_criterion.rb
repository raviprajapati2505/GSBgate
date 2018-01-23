class SchemeCriterion < ActiveRecord::Base
  include Auditable

  belongs_to :scheme_category
  has_many :scheme_criterion_texts
  has_many :scheme_mix_criteria
  has_many :scheme_criteria_requirements
  has_many :requirements, through: :scheme_criteria_requirements
  serialize :scores
  serialize :scores_b

  WEIGHT_ATTRIBUTES = ['weight', 'weight_b'].freeze
  SCORE_ATTRIBUTES = ['scores', 'scores_b'].freeze
  MIN_SCORE_ATTRIBUTES = ['minimum_score', 'minimum_score_b'].freeze
  MAX_SCORE_ATTRIBUTES = ['maximum_score', 'maximum_score_b'].freeze
  MIN_VALID_SCORE_ATTRIBUTES = ['minimum_valid_score', 'minimum_valid_score_b'].freeze
  INCENTIVE_MINUS_1_ATTRIBUTES = ['incentive_weight_minus_1', 'incentive_weight_minus_1_b'].freeze
  INCENTIVE_0_ATTRIBUTES = ['incentive_weight_0', 'incentive_weight_0_b'].freeze
  INCENTIVE_1_ATTRIBUTES = ['incentive_weight_1', 'incentive_weight_1_b'].freeze
  INCENTIVE_2_ATTRIBUTES = ['incentive_weight_2', 'incentive_weight_2_b'].freeze
  INCENTIVE_3_ATTRIBUTES = ['incentive_weight_3', 'incentive_weight_3_b'].freeze
  CALCULATE_INCENTIVE_ATTRIBUTES = ['calculate_incentive', 'calculate_incentive_b'].freeze

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

  def total_weight
    total_weight = 0
    WEIGHT_ATTRIBUTES.each do |weight_attr|
      total_weight += self.read_attribute(weight_attr)
    end
    total_weight
  end

  def has_incentive_weight_a?
    incentive_weight_minus_1 + incentive_weight_0 + incentive_weight_1 + incentive_weight_2 + incentive_weight_3 > 0
  end

  def has_incentive_weight_b?
    incentive_weight_minus_1_b + incentive_weight_0_b + incentive_weight_1_b + incentive_weight_2_b + incentive_weight_3_b > 0
  end

  def has_incentive_weight?
    has_incentive_weight_minus_1? || has_incentive_weight_0? || has_incentive_weight_1? || has_incentive_weight_2? || has_incentive_weight_3?
  end

  def has_incentive_weight_minus_1?
    total_incentive_weight_minus_1 = 0
    INCENTIVE_MINUS_1_ATTRIBUTES.each do |incentive_minus_1|
      total_incentive_weight_minus_1 += self.read_attribute(incentive_minus_1)
    end
    total_incentive_weight_minus_1 > 0
  end

  def has_incentive_weight_0?
    total_incentive_weight_0 = 0
    INCENTIVE_0_ATTRIBUTES.each do |incentive_0|
      total_incentive_weight_0 += self.read_attribute(incentive_0)
    end
    total_incentive_weight_0 > 0
  end

  def has_incentive_weight_1?
    total_incentive_weight_1 = 0
    INCENTIVE_1_ATTRIBUTES.each do |incentive_1|
      total_incentive_weight_1 += self.read_attribute(incentive_1)
    end
    total_incentive_weight_1 > 0
  end

  def has_incentive_weight_2?
    total_incentive_weight_2 = 0
    INCENTIVE_2_ATTRIBUTES.each do |incentive_2|
      total_incentive_weight_2 += self.read_attribute(incentive_2)
    end
    total_incentive_weight_2 > 0
  end

  def has_incentive_weight_3?
    total_incentive_weight_3 = 0
    INCENTIVE_3_ATTRIBUTES.each do |incentive_3|
      total_incentive_weight_3 += self.read_attribute(incentive_3)
    end
    total_incentive_weight_3 > 0
  end

  def get_incentive_weight_array(type)
    incentive_weight_array = []
    type.each do |incentive_weight|
      incentive_weight_array << self.read_attribute(incentive_weight)
    end
    incentive_weight_array
  end

  private

  def handle_scores
    SCORE_ATTRIBUTES.each_with_index do |score_attr, index|
      unless self.read_attribute(score_attr).nil?
        new_scores = []
        self..read_attribute(score_attr).each do |score|
          unless score.is_a?(Array)
            unless score.empty?
              new_scores.push([score.to_i, score.to_f])
            end
          else
            new_scores.push(score)
          end
        end
        self.write_attribute(MIN_SCORE_ATTRIBUTES[index], new_scores.first[1])
        self.write_attribute(MAX_SCORE_ATTRIBUTES[index], new_scores.last[1])
        self.write_attribute(MIN_VALID_SCORE_ATTRIBUTES[index], self.read_attribute(MIN_SCORE_ATTRIBUTES[index]))
        self.write_attribute(score_attr, YAML.load(new_scores.to_s))
      else
        self.write_attribute(MIN_SCORE_ATTRIBUTES[index], 0.0)
        self.write_attribute(MAX_SCORE_ATTRIBUTES[index], self.read_attribute(WEIGHT_ATTRIBUTES[index]))
        self.write_attribute(MIN_VALID_SCORE_ATTRIBUTES[index], 0.0)
      end
    end
  end

end
