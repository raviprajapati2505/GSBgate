class SurveyQuestion < ApplicationRecord
  # associations
  belongs_to :survey_questionnaire_version

  # validations
  validates :question_text, :question_type, presence: true
  
  enum question_type: 
    {
      single_select: "Single-Select (i.e. radio buttons)",
      multi_select: "Multi-Select (i.e. checkboxes)",
      fill_in_the_blank: "Fill-in-the-Blank"
    }
end
