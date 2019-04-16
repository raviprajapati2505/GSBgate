class AddDevelopmentTypeIdToCertificationPath < ActiveRecord::Migration[4.2]

  def up
    add_reference :certification_paths, :development_type, references: :development_type, index: true
  end

  def down
    remove_reference :certification_paths, :development_type
  end

end
