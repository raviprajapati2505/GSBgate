class Calculator::GsasServiceCalculator

  def initialize(function_name)
    @function_name = function_name
  end

  def calculate(params)
    GsasService.instance.call_function(@function_name, params)
  end

end