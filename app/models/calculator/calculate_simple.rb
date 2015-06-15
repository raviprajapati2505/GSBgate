class Calculator::CalculateSimple

  def calculate(*input)
    GsasService.instance.call_function('CalculateSimple', input)
  end

end