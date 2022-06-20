class SurveyType < ApplicationRecord
  # associations
  has_many :survey_questionnaire_versions, dependent: :destroy
  has_many :projects_surveys, dependent: :destroy

  # validations
  validates :title, presence: true

  # callback functions
  after_create_commit :create_survey_questionnaire_version

  # as many versions of questions sets are exist for this survey type
  def latest_survey_questionnaire_version
    survey_questionnaire_versions
      &.last
  end

  def latest_released_survey_questionnaire_version
    survey_questionnaire_versions
      &.released
      &.order(:version)
      &.last
  end

  def latest_survey_questions
    latest_survey_questionnaire_version
      &.survey_questions ||
      SurveyQuestion.none
  end

  def latest_released_survey_questions
    latest_released_survey_questionnaire_version
      &.survey_questions ||
      SurveyQuestion.none
  end

  def create_survey_questionnaire_version
    survey_questionnaire_versions.find_or_create_by(version: next_survey_questionnaire_version)
  end

  def next_survey_questionnaire_version
    latest_survey_questionnaire_version&.version.to_i + 1
  end
end
