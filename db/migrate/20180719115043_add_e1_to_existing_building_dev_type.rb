class AddE1ToExistingBuildingDevType < ActiveRecord::Migration
  def change
    #   create system data
    # #####################

    SchemeCriterion.create!(
        name: "Energy Demand Performance",
        number: 1,
        scores_a: YAML.load("[[-1,-1.0], [0, 0.0], [1, 1.0], [2, 2.0], [3, 3.0]]\n"),
        minimum_score_a: -1.0,
        maximum_score_a: 3.0,
        minimum_valid_score_a: -1.0,
        weight_a: 7.0,
        incentive_weight_minus_1_a: 0.0,
        incentive_weight_0_a: 0.0,
        incentive_weight_1_a: 0.0,
        incentive_weight_2_a: 0.0,
        incentive_weight_3_a: 0.0,
        calculate_incentive_a: true,
        assign_incentive_manually_a: false,
        label_a: nil,
        scores_b: nil,
        minimum_score_b: nil,
        maximum_score_b: nil,
        minimum_valid_score_b: nil,
        weight_b: 0.0,
        incentive_weight_minus_1_b: 0.0,
        incentive_weight_0_b: 0.0,
        incentive_weight_1_b: 0.0,
        incentive_weight_2_b: 0.0,
        incentive_weight_3_b: 0.0,
        calculate_incentive_b: false,
        assign_incentive_manually_b: false,
        label_b: nil,
        scheme_category: SchemeCategory.find_by(code: "E", scheme: Scheme.find_by(name: "Residential - Group", gsas_document: "Operations GSAS Assessment v2.1.html", gsas_version: "2.1", renovation:true)))
  end
end
