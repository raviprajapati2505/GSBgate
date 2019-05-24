class SchemeCriterion < ApplicationRecord
  include Auditable

  belongs_to :scheme_category, optional: true
  has_many :scheme_criterion_texts
  has_many :scheme_mix_criteria
  has_many :scheme_criteria_requirements
  has_many :requirements, through: :scheme_criteria_requirements
  has_many :scheme_criterion_incentives, inverse_of: :scheme_criterion
  has_one :scheme_criterion_epl, inverse_of: :scheme_criterion
  has_one :scheme_criterion_wpl, inverse_of: :scheme_criterion
  serialize :scores_a
  serialize :scores_b

  accepts_nested_attributes_for :scheme_criterion_incentives, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :scheme_criterion_epl, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :scheme_criterion_wpl, reject_if: :all_blank, allow_destroy: true

  WEIGHT_ATTRIBUTES = ['weight_a', 'weight_b'].freeze
  SCORE_ATTRIBUTES = ['scores_a', 'scores_b'].freeze
  MIN_SCORE_ATTRIBUTES = ['minimum_score_a', 'minimum_score_b'].freeze
  MAX_SCORE_ATTRIBUTES = ['maximum_score_a', 'maximum_score_b'].freeze
  MIN_VALID_SCORE_ATTRIBUTES = ['minimum_valid_score_a', 'minimum_valid_score_b'].freeze
  INCENTIVE_MINUS_1_ATTRIBUTES = ['incentive_weight_minus_1_a', 'incentive_weight_minus_1_b'].freeze
  INCENTIVE_0_ATTRIBUTES = ['incentive_weight_0_a', 'incentive_weight_0_b'].freeze
  INCENTIVE_1_ATTRIBUTES = ['incentive_weight_1_a', 'incentive_weight_1_b'].freeze
  INCENTIVE_2_ATTRIBUTES = ['incentive_weight_2_a', 'incentive_weight_2_b'].freeze
  INCENTIVE_3_ATTRIBUTES = ['incentive_weight_3_a', 'incentive_weight_3_b'].freeze
  CALCULATE_INCENTIVE_ATTRIBUTES = ['calculate_incentive_a', 'calculate_incentive_b'].freeze
  MANUAL_INCENTIVE_ATTRIBUTES = ['assign_incentive_manually_a', 'assign_incentive_manually_b'].freeze
  LABEL_ATTRIBUTES = ['label_a', 'label_b'].freeze

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
      total_weight += self.read_attribute(weight_attr.to_sym)
    end
    total_weight
  end

  def has_incentive_weight?(index)
    self.read_attribute(INCENTIVE_MINUS_1_ATTRIBUTES[index].to_sym) + self.read_attribute(INCENTIVE_0_ATTRIBUTES[index].to_sym) + self.read_attribute(INCENTIVE_1_ATTRIBUTES[index].to_sym) + self.read_attribute(INCENTIVE_2_ATTRIBUTES[index].to_sym) + self.read_attribute(INCENTIVE_3_ATTRIBUTES[index].to_sym) > 0 || self.scheme_criterion_incentives.count > 0
  end

  def has_manual_incentive?
    MANUAL_INCENTIVE_ATTRIBUTES.each do |manual_incentive|
      return true if self.read_attribute(manual_incentive.to_sym) == true
    end
    return false
  end

  def get_incentive_weight_array(type)
    incentive_weight_array = []
    type.each do |incentive_weight|
      incentive_weight_array << self.read_attribute(incentive_weight.to_sym)
    end
    incentive_weight_array
  end

  private

  def handle_scores
    SCORE_ATTRIBUTES.each_with_index do |score_attr, index|
      unless self.read_attribute(score_attr.to_sym).nil?
        new_scores = []
        yaml_scores = self.read_attribute(score_attr.to_sym)
        yaml_scores = YAML.load(yaml_scores) if yaml_scores.is_a?(String)
        yaml_scores.each do |score|
          unless score.is_a?(Array)
            # unless score.empty?
              new_scores.push([score.to_i, score.to_f])
            # end
          else
            new_scores.push(score)
          end
        end
        # self.write_attribute(MIN_SCORE_ATTRIBUTES[index], new_scores.first[1])
        self.send(MIN_SCORE_ATTRIBUTES[index] + '=', new_scores.first[1])
        # self.write_attribute(MAX_SCORE_ATTRIBUTES[index], new_scores.last[1])
        self.send(MAX_SCORE_ATTRIBUTES[index] + '=', new_scores.last[1])
        # self.write_attribute(MIN_VALID_SCORE_ATTRIBUTES[index], self.read_attribute(MIN_SCORE_ATTRIBUTES[index]))
        self.send(MIN_VALID_SCORE_ATTRIBUTES[index] + '=', self.read_attribute(MIN_SCORE_ATTRIBUTES[index].to_sym))
        # self.write_attribute(score_attr, YAML.load(new_scores.to_s))
        self.send(score_attr + '=', new_scores)
      else
        # self.write_attribute(MIN_SCORE_ATTRIBUTES[index], 0.0)
        self.send(MIN_SCORE_ATTRIBUTES[index] + '=', 0.0)
        # self.write_attribute(MAX_SCORE_ATTRIBUTES[index], self.read_attribute(WEIGHT_ATTRIBUTES[index]))
        self.send(MAX_SCORE_ATTRIBUTES[index] + '=', 1.0)
        # self.write_attribute(MIN_VALID_SCORE_ATTRIBUTES[index], 0.0)
        self.send(MIN_VALID_SCORE_ATTRIBUTES[index] + '=', 0.0)
      end
    end
  end

end
