class ProjectsSurvey < ApplicationRecord
    belongs_to :project, optional: true
    belongs_to :created_by, class_name: 'User', optional: true
    has_many :survey_responses, dependent: :destroy

    enum status: { active: 1, deactive: 2 }
    enum user_access: { access_publicly: 1, access_privately: 2 }

    validates :title, :survey_type_id, :status, :user_access, presence: true
end