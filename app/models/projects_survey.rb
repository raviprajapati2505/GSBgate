class ProjectsSurvey < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged  # friendly id gem for the pretty url for survey responses

	belongs_to :project
	belongs_to :survey_type
  belongs_to :survey_questionnaire_version, optional: true
	belongs_to :created_by, class_name: 'User'
	has_many :survey_responses, dependent: :destroy
	after_save :assign_version, if: :saved_change_to_released_at?

	enum status: { active: 1, deactive: 2 }
	enum user_access: { access_publicly: 1, access_privately: 2 }

	validates :title, :survey_type_id, :status, :user_access, presence: true
	validates_uniqueness_of :survey_type_id, scope: :project

	def released?
		released_at.present?
	end
	
	def is_public?
		user_access == 'access_publicly'
	end

	def is_private?
		user_access == 'access_privately'
	end

	def is_user_exist(email)
		User.find_by_email(email).present?
	end

	def assign_version
		self.update_column(:survey_questionnaire_version_id, survey_type.latest_released_survey_questionnaire_version.id)
	end
end