class SurveyQuestionnaireVersion < ApplicationRecord
  # associations
  belongs_to :survey_type
  has_many :survey_questions, dependent: :destroy
  has_many :projects_surveys, dependent: :destroy

  # validations
  validates :version, presence: true
  validates :survey_type_id, uniqueness: { scope: [:version] }

  # nested attributes
  accepts_nested_attributes_for :survey_questions, reject_if: :all_blank, allow_destroy: true
  
  # scopes
  default_scope { order(:version) }

  scope :released, -> {
    where.not(released_at: nil)
  }

  def released?
    released_at.present?
  end

end
