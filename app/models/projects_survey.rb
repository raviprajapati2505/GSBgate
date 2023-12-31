class ProjectsSurvey < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged  # friendly id gem for the pretty url for survey responses

  # associations
  belongs_to :project
  belongs_to :survey_type
  belongs_to :survey_questionnaire_version, optional: true
  has_many :survey_responses, dependent: :destroy

  # enums
  enum status: 
    { 
      active: 1,
      inactive: 2 
    }

  enum user_access: 
    { 
      access_publicly: 1,
      access_privately: 2
    }

  # validations
  validates :title, :survey_type_id, :status, :user_access, presence: true
  validates_uniqueness_of :title
  validates_uniqueness_of :survey_type_id, scope: :project

  # callbacks
  after_save :assign_version, if: :saved_change_to_released_at?

  def released?
    released_at.present?
  end

  def expired?
    end_date < Date.today rescue false
  end

  def is_public?
    user_access == 'access_publicly'
  end

  def is_private?
    user_access == 'access_privately'
  end

  def assign_version
    self.update_column(:survey_questionnaire_version_id, survey_type.latest_released_survey_questionnaire_version.id)
  end
end