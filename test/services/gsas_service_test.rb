require 'test_helper'

class GsasServiceTest < ActiveSupport::TestCase
  test 'gsas service function call should return success' do
    response = GsasService.instance.call_calculator('EnergyPerformanceEvaluation', {criteria: ['RAILWAYS_E.1', 'MOSQUE_E.1', 'RAILWAYS_E.2', 'MOSQUE_E.2'], zone: '', terrain_class: '', zone_location: '', depth: 15, area: 7, height: 24, volume: 460})
    assert_equal GsasService::STATUS_SUCCESS, response[:status], 'invalid response[:status]'
    assert_equal 2, response[:scores][0][:score], 'invalid response[:score]'
  end

  test 'gsas service function call should return error' do
    response = GsasService.instance.call_calculator('UnexistingFunction', {x: 1000, y: 3})
    assert_equal GsasService::STATUS_ERROR, response[:status], 'invalid response[:status]'
    assert_nil response[:score], 'response[:score] should not exist'
  end
end