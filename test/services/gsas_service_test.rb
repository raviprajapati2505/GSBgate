require 'test_helper'

class GsasServiceTest < ActiveSupport::TestCase
  test 'gsas service function call should return success' do
    response = GsasService.instance.call_function('CalculateSimple', {x: 1000, y: 3})
    assert_equal GsasService::STATUS_SUCCESS, response[:status], 'invalid response[:status]'
    assert_equal 3, response[:score], 'invalid response[:score]'
  end

  test 'gsas service function call should return error' do
    response = GsasService.instance.call_function('UnexistingFunction', {x: 1000, y: 3})
    assert_equal GsasService::STATUS_ERROR, response[:status], 'invalid response[:status]'
    assert_nil response[:score], 'response[:score] should not exist'
  end
end