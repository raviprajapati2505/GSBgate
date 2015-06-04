class FieldDatum::IntegerValue < FieldDatum

  validates_numericality_of :integer_value, only_integer: true, allow_blank: true

  def value
    self.integer_value
  end

  def value=(new_value)
    write_attribute(:integer_value, new_value)
  end

end
