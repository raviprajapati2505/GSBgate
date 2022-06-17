class SurveyQuestion < ApplicationRecord
  # to set the position
  acts_as_list

  enum question_type: 
    {
      fill_in_the_blank: "Fill-in-the-Blank",
      single_select: "Single-Select (i.e. radio buttons)",
      multi_select: "Multi-Select (i.e. checkboxes)"
    }

  # associations
  belongs_to :survey_questionnaire_version
  has_many :question_options, dependent: :destroy
  has_many :question_responses, dependent: :destroy

  # validations
  validates :question_text, :question_type, presence: true

  # nested attributes
  accepts_nested_attributes_for :question_options, reject_if: :all_blank, allow_destroy: true

  # scopes
  scope :by_position, -> { order(:position) }
end
