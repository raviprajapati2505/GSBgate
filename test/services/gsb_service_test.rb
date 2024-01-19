require 'test_helper'

class GsbServiceTest < ActiveSupport::TestCase
  test 'gsb service UnexistingFunction should return error' do
    response = GsbService.instance.call_calculator('UnexistingFunction', {x: 1000, y: 3})
    assert_equal GsbService::STATUS_ERROR, response[:status], 'response[:status] == error'
    assert_nil response[:score], 'response[:score] should not exist'
  end

  test 'gsb service EnergyPerformanceEvaluation should return success' do
    response = GsbService.instance.call_calculator('EnergyPerformanceEvaluation', {criteria: ['RAILWAYS_E.1', 'MOSQUE_E.1', 'RAILWAYS_E.2', 'MOSQUE_E.2'], zone: '', terrain_class: '', zone_location: '', depth: 15, area: 7, height: 24, volume: 460})
    assert_equal GsbService::STATUS_SUCCESS, response[:status], 'status is not success'
    assert_equal 2, response[:scores][0][:score], 'score is not 0'
  end

  test 'gsb service ProximityToAmenities should return success' do
    response = GsbService.instance.call_calculator('ProximityToAmenities', {criteria: ['UC.7'], PublicService0: 0, PublicService1: 0, PublicService2: 0, PublicService3: 0, Worship0: 0, Worship1: 0, Worship2: 0, Worship3: 0, RetailServices0: 0, RetailServices1: 0, RetailServices2: 0, RetailServices3: 0, RetailGoods0: 0, RetailGoods1: 0, RetailGoods2: 0, RetailGoods3: 0, RetailFoods0: 0, RetailFoods1: 0, RetailFoods2: 0, RetailFoods3: 0})
    assert_equal GsbService::STATUS_SUCCESS, response[:status], 'status is not success'
    assert_equal 0, response[:scores][0][:score], 'score is not 0'

    response = GsbService.instance.call_calculator('ProximityToAmenities', {criteria: ['UC.7'], PublicService0: 1, PublicService1: 1, PublicService2: 1, PublicService3: 1, Worship0: 1, Worship1: 1, Worship2: 1, Worship3: 1, RetailServices0: 1, RetailServices1: 1, RetailServices2: 1, RetailServices3: 1, RetailGoods0: 1, RetailGoods1: 1, RetailGoods2: 1, RetailGoods3: 1, RetailFoods0: 1, RetailFoods1: 1, RetailFoods2: 1, RetailFoods3: 1})
    assert_equal GsbService::STATUS_SUCCESS, response[:status], 'status is not success'
    assert_equal 2, response[:scores][0][:score], 'score is not 2'
  end

end
