class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: [ :system_admin, :user, :gord_top_manager, :gord_manager ]

  has_many :owned_projects, class_name: 'Project', inverse_of: :owner
  has_many :documents
  has_many :scheme_mix_criteria_documents
  has_many :project_authorizations, dependent: :delete_all
  has_many :projects, through: :project_authorizations
  has_many :requirement_data, dependent: :nullify
  has_many :scheme_mix_criteria, inverse_of: :certifier, foreign_key: 'certifier_id'
  has_many :notifications
  has_many :user_tasks, dependent: :destroy

  default_scope { order(email: :asc) }

  scope :not_owning_project, ->(project) {
    where.not(id: project.owner_id)
  }

  scope :not_authorized_for_project, ->(project) {
    where.not('exists(select id from project_authorizations where user_id = users.id and project_id = ?)', project.id)
  }

  scope :without_permissions_for_project, ->(project) {
    where(role: 1) & not_owning_project(project) & not_authorized_for_project(project)
  }

  scope :authorized_for_project, ->(project) {
    joins(:project_authorizations).where(project_authorizations: {project_id: project.id})
  }

  scope :with_assessor_project_role, -> {
    where('project_authorizations.role in (0, 1)')
  }

  scope :with_certifier_project_role, -> {
    where('project_authorizations.role in (3, 4)')
  }

  def certifier_manager?(project)
    project_authorizations.each do |project_authorization|
      if project_authorization.project == project && project_authorization.certifier_manager?
        return true
      end
    end
    return false
  end

  def project_manager?(project)
    project_authorizations.each do |project_authorization|
      if project_authorization.project == project && project_authorization.project_manager?
        return true
      end
    end
    return false
  end

  def enterprise_account?(project)
    project_authorizations.each do |project_authorization|
      if project_authorization.project == project && project_authorization.enterprise_account?
        return true
      end
    end
    return false
  end

  def project_team_member?(project)
    project_authorizations.each do |project_authorization|
      if project_authorization.project == project && project_authorization.project_team_member?
        return true
      end
    end
    return false
  end

  before_validation :assign_default_role, on: :create

  validates :role, inclusion: User.roles.keys

  # Question : should only the remaining tasks be returned or also the already finished tasks ?

  # return certification_path list with task descriptions
  # def self::system_admin_tasks
    # if PCR track : Check PCR track payment and status to in_review
  # end

  # return certification_path, scheme_mix_criteria, requirement, document list with task descriptions
  # def project_manager_tasks
    #! process screening comments and set status to (if PCR track) awaiting_pcr_admittance
    # ---
    # if PCR track : process review comments and set status to in_verification
    #! if certification_rejected : (if appeal) set status to in_verification
    #! if awaiting_approval: set status to in_verification (if no agreement and appealed)
  # end

  # return requirement list with task descriptions
  # def project_member_tasks
    # accept invitation
  # end

  # return certification_path and scheme_mix_criteria list with task descriptions
  # def certifier_manager_tasks
    # if PCR track : set status to reviewed ?
  # end

  # return scheme_mix_criteria list with task descriptions
  # def certifier_member_tasks
    # if PCR track : review criterion and set criterion status to approved or resubmit ?
  # end

  private
  def assign_default_role
    self.role = :user if self.role.nil?
  end

end
