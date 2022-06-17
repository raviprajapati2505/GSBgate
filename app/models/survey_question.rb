class SurveyQuestion < ApplicationRecord
  
  enum question_type: 
    {
      single_select: "Single-Select (i.e. radio buttons)",
      multi_select: "Multi-Select (i.e. checkboxes)",
      fill_in_the_blank: "Fill-in-the-Blank"
    }

  # associations
  belongs_to :survey_questionnaire_version
  has_many :question_options, dependent: :destroy
  has_many :question_responses, dependent: :destroy

  # validations
  validates :question_text, :question_type, presence: true

  # nested attributes
  accepts_nested_attributes_for :question_options, reject_if: :all_blank, allow_destroy: true
end
