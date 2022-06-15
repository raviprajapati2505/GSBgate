class ProjectsSurvey < ApplicationRecord
    extend FriendlyId
    friendly_id :title, use: :slugged  # friendly id gem for the pretty url for survey responses

    belongs_to :project
    belongs_to :survey_type
    belongs_to :created_by, class_name: 'User'
    has_many :survey_responses, dependent: :destroy

    enum status: { active: 1, deactive: 2 }
    enum user_access: { access_publicly: 1, access_privately: 2 }

    validates :title, :survey_type_id, :status, :user_access, presence: true
    #validates :project, uniqueness: {scope:[:survey_type]}
    validates_uniqueness_of :survey_type_id, scope: :project
end