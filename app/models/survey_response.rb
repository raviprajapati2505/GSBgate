class SurveyResponse < ApplicationRecord
    belongs_to :projects_survey
    
    validates :name, presence: true
    #validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validate :email_based_on_survey_access_type

    private

    def email_based_on_survey_access_type
        puts projects_survey.user_access
        binding.pry    
    end
end
