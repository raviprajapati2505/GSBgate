# Subclasses of this class can be found in the folder 'field_datum'
class FieldDatum < ApplicationRecord
  belongs_to :calculator_datum, optional: true
  belongs_to :field, optional: true

  # This method should be overloaded in the subclass
  def value
    raise NotImplementedError("#{self.class.name}#value() is an abstract method and thus not implemented.")
  end
end
