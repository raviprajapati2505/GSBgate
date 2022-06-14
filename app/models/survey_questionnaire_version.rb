class SurveyQuestionnaireVersion < ApplicationRecord
  # associations
  belongs_to :survey_type
  has_many :survey_questions, dependent: :destroy

  # validations
  validates :version, presence: true
  validates :survey_type_id, uniqueness: { scope: [:version] }

  # nested attributes
  accepts_nested_attributes_for :survey_questions, reject_if: :all_blank, allow_destroy: true
end
