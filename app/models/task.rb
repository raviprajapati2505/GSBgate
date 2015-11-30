class Task < ActiveRecord::Base
  belongs_to :taskable, polymorphic: true
  belongs_to :user
  belongs_to :project
  belongs_to :certification_path

  # to content the find_each function
  self.primary_key = 'id'
end