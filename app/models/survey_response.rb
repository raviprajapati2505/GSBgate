class SurveyResponse < ApplicationRecord
    belongs_to :projects_surveys, optional: true
    validates :name, presence: true
    validates :email, presence: true
end
