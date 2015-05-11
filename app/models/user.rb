class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  enum role: [ :admin, :certifier, :registered, :anonymous ]

  has_many :project_authorizations
  has_many :projects, through: :project_authorizations

  scope :with_role_different_from, ->(role) {
    where.not(role: role)
  }

  scope :with_no_role, -> {
    where(role: nil)
  }

  scope :with_no_admin_role, -> {
    with_role_different_from(User.roles[:admin]) | with_no_role
  }

  before_validation :assign_default_role, on: :create

  validates :role, inclusion: User.roles.keys

  private
  def assign_default_role
    self.role = :anonymous if self.role.nil?
  end

end
