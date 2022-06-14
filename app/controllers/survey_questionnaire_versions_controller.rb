class SurveyQuestionnaireVersionsController < AuthenticatedController
  load_and_authorize_resource class: false, except: [:create]
  before_action :set_survey_type
  before_action :set_latest_survey_questionnaire_version, only: [:form, :update]
  before_action :set_latest_survey_questions, only: [:form]

  def show
    @page_title = t('survey_type.index.title_html')
  end

  def form
    @page_title = t('survey_questionnaire_version.form.title_html', title: @survey_type.title)

    @survey_questions = @latest_survey_questionnaire_version.survey_questions.new unless @survey_questions.present?

    # post or patch
    set_sumbit_method_type
  end

  def create
    # create new survey questionnaire version as previous one is released
    @latest_survey_questionnaire_version = @survey_type.create_survey_questionnaire_version

    save_survey_questions!
  end

  def update
    save_survey_questions!
  end

  private

    def set_survey_type
      @survey_type = SurveyType.find(params[:survey_type_id])
    end

    def set_latest_survey_questionnaire_version
      @latest_survey_questionnaire_version = @survey_type.latest_survey_questionnaire_version
    end

    def set_latest_survey_questions
      @survey_questions = @survey_type.latest_survey_questions
    end
    
    def save_survey_questions!
      if params[:button].present? && params[:button] == 'save-and-release'
        @latest_survey_questionnaire_version.released = true
      end

      if @latest_survey_questionnaire_version.update(survey_questionnaire_version_params)
        redirect_to survey_type_path(@survey_type), notice: 'Survey questions are successfully stored.'
      else
        set_sumbit_method_type

        render :form
      end
    end

    def set_sumbit_method_type
      if @latest_survey_questionnaire_version.released?
        @submit_method = 'POST'
      else
        @submit_method = 'PATCH'
      end
    end

    def survey_questionnaire_version_params
      if params[:action] == 'create'
        params.
          require(:survey_questionnaire_version).
            permit(
              survey_questions_attributes: 
                [ 
                  :question_text,
                  :description, 
                  :mandatory, 
                  :position, 
                  :question_type, 
                  :_destroy, 
                    question_options_attributes:
                      [ 
                        :option_text, 
                        :score, 
                        :_destroy
                      ]
                ]
            )

      else
        params.
          require(:survey_questionnaire_version).
            permit(
              survey_questions_attributes: 
                [ 
                  :id,
                  :question_text,
                  :description, 
                  :mandatory, 
                  :position, 
                  :question_type, 
                  :_destroy, 
                    question_options_attributes:
                      [ 
                        :id,
                        :option_text, 
                        :score, 
                        :_destroy
                      ]
                ]
            )
      end
    end
end
