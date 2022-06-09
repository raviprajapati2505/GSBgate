class SurveyType < ApplicationRecord
    validates :title, presence: true
end
