class SurveyResponse < ApplicationRecord
	belongs_to :projects_survey
	has_many :question_responses, dependent: :destroy

	validates :name, presence: true
	validate :email_based_on_survey_access_type

	# nested attributes
	accepts_nested_attributes_for :question_responses, reject_if: :all_blank, allow_destroy: true

	private

	def email_based_on_survey_access_type
		if projects_survey.is_private?
				if email.blank?
						errors.add(:email, 'email id cant be blank')
				end
				user_exist = projects_survey.is_user_exist(email)
				if !user_exist
					errors.add(:email, 'email is not associate with any of account !! try different one')
				end
		end
	end
end
