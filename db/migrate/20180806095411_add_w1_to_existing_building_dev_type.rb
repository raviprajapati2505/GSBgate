class AddW1ToExistingBuildingDevType < ActiveRecord::Migration[4.2]
  def change
    #  create system data
    # ####################

    criterion = SchemeCriterion.create!(
                       name: "Water Consumption and Reuse",
                       number: 2,
                       scores_a: YAML.load("[[-1,-1.0],[0,0.0],[1,1.0],[2,2.0],[3,3.0]]\n"),
                       minimum_score_a: -1.0,
                       maximum_score_a: 3.0,
                       minimum_valid_score_a: -1.0,
                       weight_a: 10.0,
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
                       scheme_category: SchemeCategory.find_by(code: "W", scheme: Scheme.find_by(name: "Residential - Group", gsas_document: "Operations GSAS Assessment v2.1.html", gsas_version: "2.1", renovation: true))
    )

    requirement_1 = Requirement.create!(name: 'Rainwater and stormwater collection and reuse plan')
    requirement_2 = Requirement.create!(name: 'Greywater and blackwater treatment and reuse plan')
    requirement_3 = Requirement.create!(name: 'Cooling Tower Specifications and Plans')
    requirement_4 = Requirement.create!(name: 'HVAC Systems Specifications')
    requirement_5 = Requirement.create!(name: 'Condensate Water Collection Plans and Specifications')

    SchemeCriteriaRequirement.create!(scheme_criterion_id: criterion.id, requirement: requirement_1)
    SchemeCriteriaRequirement.create!(scheme_criterion_id: criterion.id, requirement: requirement_2)
    SchemeCriteriaRequirement.create!(scheme_criterion_id: criterion.id, requirement: requirement_3)
    SchemeCriteriaRequirement.create!(scheme_criterion_id: criterion.id, requirement: requirement_4)
    SchemeCriteriaRequirement.create!(scheme_criterion_id: criterion.id, requirement: requirement_5)

    SchemeCriterionText.create!(name: 'SCORE', html_text: '<table class="table table-bordered">
<colgroup>
<col></col>
<col></col>
</colgroup>
<tbody>
<tr>
<td>
<p>Score </p>
</td>
<td>
<p>WPC<span>Con</span>(X)</p>
</td>
</tr>
<tr>
<td>
<p>-1 </p>
</td>
<td>
<p>X &ge; 1.00</p>
</td>
</tr>
<tr>
<td>
<p>0 </p>
</td>
<td>
<p>0.85 &lt; X &le; 1.00</p>
</td>
</tr>
<tr>
<td>
<p>1 </p>
</td>
<td>
<p>0.75 &lt; X &le; 0.85</p>
</td>
</tr>
<tr>
<td>
<p>2 </p>
</td>
<td>
<p>0.65 &lt; X &le; 0.75</p>
</td>
</tr>
<tr>
<td>
<p>3 </p>
</td>
<td>
<p>X &le; 0.65</p>
</td>
</tr>
</tbody>
</table>
', display_weight: 6, visible: true, scheme_criterion_id: criterion.id)
    SchemeCriterionText.create!(name: 'SUBMITTAL', html_text: '<p>All projects must submit the Water Calculator and the following supporting documents:</p>
<ul>
<li><span>&bull;	</span>Rainwater and stormwater collection and reuse plan.</li>
<li><span>&bull;	</span>Greywater and blackwater treatment and reuse plan.</li>
<li><span>&bull;	</span>Cooling Tower Specifications and Plans.</li>
<li><span>&bull;	</span>HVAC Systems Specifications.</li>
<li><span>&bull;	</span>Condensate Water Collection Plans and Specifications. <span></span></li>
</ul>', display_weight: 5, visible: true, scheme_criterion_id: criterion.id)
    SchemeCriterionText.create!(name: 'MEASUREMENT', html_text: '<p>All projects will complete the Water Calculator to determine the cumulative water consumption for all occupancy types within a single building. Cumulative water consumption and reuse is determined by the factors used for water efficiency in addition to:</p>
<ul>
<li><span>&bull;	</span>Rainwater and stormwater collection and reuse plan.</li>
<li><span>&bull;	</span>Greywater and blackwater treatment and reuse plan.</li>
<li><span>&bull;	</span>Cooling Tower.</li>
<li><span>&bull;	</span>HVAC Systems.</li>
<li><span>&bull;	</span>Condensate Water Collection. </li>
</ul>
<p>&nbsp;</p>
<p>Based on input parameters provided by the project, the application conducts multiple calculations to determine the building&rsquo;s estimated water consumption and reuse. </p><div>
<div>
<p>WPC<span>Con</span> =</p>
</div>
<div>
<img alt="138615.png" src="Typologies-GSAS-Design-Assessment-v2.1_Medium-web-resources/image/138615.png"/>
</div>
<div>
<p>WD<span>cal_occupant</span>+ WD<span>cal_irrigation</span>- WS<span>cal_reuse</span></p>
</div>
<div>
<p>WD<span>ref_occupant </span>+<span> </span>WD<span>ref_irrigation</span></p>
</div>
</div>
<p>&nbsp;</p>
<p>&nbsp;</p>
<p>WS<span>cal_reuse</span> =Water Supply from Reuse Strategies. </p>
<p>&nbsp;</p>
<p>The annual net water demand is calculated by subtracting water supply from reuse strategies (WS<span>cal_reuse</span>) from the summation of water consumptions (WD<span>cal_occupant</span> + WD<span>cal_ irrigation</span>).</p>', display_weight: 3, visible: true, scheme_criterion_id: criterion.id)
    SchemeCriterionText.create!(name: 'MEASUREMENT PRINCIPLE', html_text: '<p>All projects will demonstrate recycling, treatment and reuse of water in relation to the baseline and targets outlined in the Water Calculator.</p>
<p>&nbsp;</p>', display_weight: 2, visible: true, scheme_criterion_id: criterion.id)
    SchemeCriterionText.create!(name: 'DESCRIPTION', html_text: '<p>Recycle, treat on-site and reuse water in order to minimize in order to reduce the burden on municipal supply and treatment systems.</p>
<p>&nbsp;</p>', display_weight: 1, visible: true, scheme_criterion_id: criterion.id)
  end
end
