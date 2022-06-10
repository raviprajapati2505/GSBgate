class SurveyType < ApplicationRecord
  # associations
  has_many :survey_questionnaire_versions, dependent: :destroy
  has_many :projects_surveys, dependent: :destroy

  # validations
  validates :title, presence: true

  # as many versions of questions sets are exist for this survey type
  def latest_survey_questions
    survey_questionnaire_versions
      .order(:version)
      &.last
      &.survey_questions ||
      SurveyQuestion.none
  end
end
