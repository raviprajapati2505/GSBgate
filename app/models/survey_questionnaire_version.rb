class SurveyQuestionnaireVersion < ApplicationRecord
  # associations
  belongs_to :survey_type
  has_many :survey_questions, dependent: :destroy

  # validations
  validates :version, presence: true
end
