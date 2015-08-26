class SchemeMixCriteriaDocument < ActiveResource
  enum status: [ :awaiting_approval, :approved, :rejected, :superseded ]

  belongs_to :document
  belongs_to :scheme_mix_criterion
  has_many :scheme_mix_criteria_document_comments, :dependent => :delete_all
  has_many :commenters, through: :scheme_mix_criteria_document_comments, source: :user

  after_initialize :init

  private

  def init
    # Set default status
    self.status ||= :awaiting_approval
  end
end
