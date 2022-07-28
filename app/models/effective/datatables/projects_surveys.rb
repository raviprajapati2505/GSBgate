module Effective
  module Datatables
    class ProjectsSurveys < Effective::Datatable
      include ActionView::Helpers::TranslationHelper

      datatable do
        col :project_code, label: t('models.effective.datatables.projects.lables.project_code'), sql_column: 'projects.code' do |rec|          
          link_to_if(!current_user.users_admin?,
            rec.project_code,
            project_path(rec.project_id)
          )
        end

        col :project_name

        col :survey_title, sql_column: 'projects_surveys.title' do |rec|          
          link_to_if(!current_user.users_admin? && rec&.released_at.present?,
            rec.survey_title,
            project_survey_path(rec.project_id, rec.projects_survey_id)
          )
        end
        
        col :survey_type_name do |rec|
          if rec.survey_questionnaire_version_id.present?
            link_to(
              rec.survey_type_name, 
              survey_type_survey_questionnaire_version_path(rec.survey_type_id, rec.survey_questionnaire_version_id)
            )
          end
        end

        col :survey_status, sql_column: 'projects_surveys.status', search: { as: :select, collection: Proc.new { ProjectsSurvey.statuses.map { |k ,v| [k.titleize, v] }.uniq } } do |rec|
          ProjectsSurvey.statuses.key(rec.survey_status).titleize rescue ''
        end.search do |collection, term, column, index|
          unless (collection.class == Array)
            collection.where("projects_surveys.status = :status", status: term)
          else
            collection
          end
        end

        col :user_access, sql_column: 'projects_surveys.user_access', search: { as: :select, collection: Proc.new { ProjectsSurvey.user_accesses.map { |k ,v| [k.titleize, v] }.uniq } } do |rec|
          rec.user_access.titleize rescue ''
        end.search do |collection, term, column, index|
          unless (collection.class == Array)
            collection.where("projects_surveys.user_access = :user_access", user_access: term)
          else
            collection
          end
        end

        col :survey_released?, sql_column: 'projects_surveys.released_at', search: { as: :select, collection: Proc.new { ['Yes', 'No'] } } do |rec|
          if rec.released? 
            "Yes"
          else
            "No"
          end
        end.search do |collection, term, column, index|
          unless (collection.class == Array)
            if term == 'Yes'
              collection.where("projects_surveys.released_at IS NOT NULL")
            else
              collection.where("projects_surveys.released_at IS NULL")
            end
          else
            collection
          end
        end

        col :survey_expired?, sql_column: 'projects_surveys.end_date', search: { as: :select, collection: Proc.new { ['Yes', 'No'] } } do |rec|
          if rec.expired? 
            "Yes"
          else
            "No"
          end
        end.search do |collection, term, column, index|
          unless (collection.class == Array)
            if term == 'Yes'
              collection.where("DATE(projects_surveys.end_date) < :current_date", current_date: Date.today)
            else
              collection.where("DATE(projects_surveys.end_date) > :current_date", current_date: Date.today)
            end
          else
            collection
          end
        end


        col :released_at, col_class: 'date-range-filter', sql_column: 'projects_surveys.released_at', as: :datetime do |rec|
          rec.released_at&.strftime('%e %b - %Y')

        end.search do |collection, term, column, index|
          from_date = term.split(' - ')[0]&.to_datetime
          to_date = term.split(' - ')[1]&.to_datetime

          unless (collection.class == Array)
            collection.where("DATE(projects_surveys.released_at) BETWEEN :from_date AND :to_date", from_date: from_date, to_date: to_date)
          else
            collection
          end
        end

        col :end_date, col_class: 'date-range-filter', sql_column: 'projects_surveys.end_date', as: :datetime do |rec|
          rec.end_date&.strftime('%e %b - %Y')

        end.search do |collection, term, column, index|
          from_date = term.split(' - ')[0]&.to_datetime
          to_date = term.split(' - ')[1]&.to_datetime

          unless (collection.class == Array)
            collection.where("DATE(projects_surveys.end_date) BETWEEN :from_date AND :to_date", from_date: from_date, to_date: to_date)
          else
            collection
          end
        end
      end

      collection do
        ProjectsSurvey
          .joins("LEFT OUTER JOIN projects ON projects_surveys.project_id = projects.id")
          .joins("LEFT OUTER JOIN survey_types ON projects_surveys.survey_type_id = survey_types.id")
          .joins("LEFT JOIN survey_questionnaire_versions ON projects_surveys.survey_questionnaire_version_id = survey_questionnaire_versions.id")
          .select("projects.id as project_id")
          .select("projects.code as project_code")
          .select("projects.name as project_name")
          .select("survey_types.id as survey_type_id")
          .select("survey_types.title as survey_type_name")
          .select("survey_questionnaire_versions.id as survey_questionnaire_version_id")
          .select("projects_surveys.id as projects_survey_id")
          .select("projects_surveys.title as survey_title")
          .select("projects_surveys.status as survey_status")
          .select("projects_surveys.end_date as end_date")
          .select("projects_surveys.user_access as user_access")
          .select("projects_surveys.released_at as released_at")
      end
    end
  end
end