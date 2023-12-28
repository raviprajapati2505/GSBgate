class FieldDatum::StringValue < FieldDatum

  def value
    self.string_value
  end

  def value=(new_value)
    write_attribute(:string_value, new_value)
  end

end
