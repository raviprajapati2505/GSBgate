class SchemeMix < ActiveRecord::Base
  belongs_to :certification_path
  belongs_to :scheme
  has_many :scheme_mix_criteria

  after_create :create_descendant_records

  private
    def create_descendant_records
      scheme.scheme_criteria.each do |scheme_criterion|
        SchemeMixCriterion.create(targeted_score: 0, scheme_mix: self, scheme_criterion: scheme_criterion)
      end
    end

end
