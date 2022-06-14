class QuestionOption < ApplicationRecord
  # associations
  belongs_to :survey_question

  # validations
  validates :option_text, presence: true
end
