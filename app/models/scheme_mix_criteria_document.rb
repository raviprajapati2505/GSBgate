class SchemeMixCriteriaDocument < AuditableRecord
  enum status: { awaiting_approval: 0, approved: 1, rejected: 2, superseded: 3 }

  belongs_to :document
  belongs_to :scheme_mix_criterion

  after_initialize :init

  def name
    self.document.name
  end

  def content_type
    self.document.content_type
  end

  def path
    self.document.path
  end

  def size
    self.document.size
  end

  private

  def init
    # Set default status
    self.status ||= :awaiting_approval
  end
end
