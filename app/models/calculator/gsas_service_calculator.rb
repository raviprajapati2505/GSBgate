class Calculator::GsasServiceCalculator

  def initialize(calculator_name)
    @calculator_name = calculator_name
  end

  def calculate(params)
    GsasService.instance.call_calculator(@calculator_name, params)
  end

end