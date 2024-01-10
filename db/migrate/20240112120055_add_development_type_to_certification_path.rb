class AddDevelopmentTypeToCertificationPath < ActiveRecord::Migration[7.0]
  def change
    add_reference :certification_paths, :development_type, references: :development_type, index: true
  end
end
