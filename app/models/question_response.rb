class QuestionResponse < ApplicationRecord
  # associations
  belongs_to :survey_question
  belongs_to :survey_response

  # validations
  validates :value, presence: true, if: :mandatory_question?

  # scopes
  scope :with_project_survey, -> (project_survey_id) {
    joins(:survey_response).
      where(
        "survey_responses.projects_survey_id = :projects_survey_id", 
        projects_survey_id: project_survey_id
      )
  }

  private

  def mandatory_question?
    survey_question.mandatory?
  end
end
