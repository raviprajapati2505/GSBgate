# Subclasses of this class can be found in the folder 'field_datum'
class FieldDatum < ActiveRecord::Base
  belongs_to :calculator_datum
  belongs_to :field

  # This method should be overloaded in the subclass
  def value
    raise NotImplementedError("#{self.class.name}#value() is an abstract method and thus not implemented.")
  end
end
