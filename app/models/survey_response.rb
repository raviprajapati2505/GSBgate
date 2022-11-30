class SurveyResponse < ApplicationRecord
  # associations
  belongs_to :projects_survey
  has_many :question_responses, dependent: :destroy

  # validations
  validates :name, presence: false
  validate :email_based_on_survey_access_type

  # nested attributes
  accepts_nested_attributes_for :question_responses, reject_if: :all_blank, allow_destroy: true

  private

  def email_based_on_survey_access_type
    if projects_survey.is_private?
      if email.blank?
        errors.add(:email, 'email id cant be blank')
      else
        if is_user_in_system?
          errors.add(:email, 'this survey is for GSAS users only')
        end
      end
    end
  end

  def is_user_in_system?
    User.find_by_email(email).present?
  end
end
