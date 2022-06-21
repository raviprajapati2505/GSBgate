class QuestionResponse < ApplicationRecord
  # associations
  belongs_to :survey_question
  belongs_to :survey_response

  # validations
  validates :value, presence: true, if: :mandatory_question?

  private

  def mandatory_question?
    survey_question.mandatory?
  end
end
