class SurveyType < ApplicationRecord
    has_many :projects_surveys
    validates :title, presence: true
end
