class Task < ApplicationRecord
  belongs_to :taskable, polymorphic: true, optional: true
  belongs_to :user, optional: true
  belongs_to :project, optional: true
  belongs_to :certification_path, optional: true

  delegate :name, to: :project, prefix: :project

  # to content the find_each function
  self.primary_key = 'id'
end