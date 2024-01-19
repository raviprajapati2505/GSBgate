class Calculator::GsbServiceCalculator

  def initialize(calculator_name)
    @calculator_name = calculator_name
  end

  def calculate(params)
    GsbService.instance.call_calculator(@calculator_name, params)
  end

end