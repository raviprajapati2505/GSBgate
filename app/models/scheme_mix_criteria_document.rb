class SchemeMixCriteriaDocument < ActiveRecord::Base
  include Auditable
  include Taskable

  enum status: { awaiting_approval: 0, approved: 1, rejected: 2 }

  belongs_to :document, dependent: :destroy
  belongs_to :scheme_mix_criterion

  after_initialize :init

  scope :for_category, ->(category) {
    includes(:scheme_mix_criterion => [:scheme_criterion]).where(scheme_criteria: {scheme_category_id: category.id})
  }

  scope :for_scheme_mix, ->(scheme_mix) {
    includes(:scheme_mix_criterion).where(scheme_mix_criteria: {scheme_mix_id: scheme_mix.id})
  }

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
