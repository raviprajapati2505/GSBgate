class QuestionResponse < ApplicationRecord
  # associations
  belongs_to :survey_question
  belongs_to :survey_response
end
