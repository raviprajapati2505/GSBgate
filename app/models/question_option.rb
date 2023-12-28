class QuestionOption < ApplicationRecord
  # to set the position
  acts_as_list scope: :survey_question

  # associations
  belongs_to :survey_question

  # validations
  validates :option_text, presence: true

  # scopes
  default_scope { order(:position) }
end
