class Task < ActiveRecord::Base
  belongs_to :taskable, polymorphic: true
  belongs_to :user
  belongs_to :project
  belongs_to :certification_path
end