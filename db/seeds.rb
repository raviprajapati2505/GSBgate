# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Add admin user
User.create!(email: 'admin@vito.be', password: 'gsas-secret', password_confirmation: 'gsas-secret', role: :system_admin)

# Category's
Category.create!(code: 'UC', name: 'Urban Connectivity', weight: 8)
Category.create!(code: 'S', name: 'Site', weight: 9)
Category.create!(code: 'E', name: 'Energy', weight: 24)
Category.create!(code: 'W', name: 'Water', weight: 16)
Category.create!(code: 'M', name: 'Materials', weight: 8)
Category.create!(code: 'IE', name: 'Indoor Environment', weight: 16)
Category.create!(code: 'CE', name: 'Cultural & Economic', weight: 13)
Category.create!(code: 'MO', name: 'Management & Operations', weight: 6)

# Criteria
Criterion.create!(code: 'UC.1', name: 'Proximity to Infrastructure', category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.2', name: 'Load on Local Traffic Conditions', category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.3', name: 'Public Transportation', category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.4', name: 'Private Transportation', category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.5', name: 'Sewer & Waterway Contamination', category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.6', name: 'Acoustic Conditions', category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.7', name: 'Proximity to Amenities', category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.8', name: 'Accessibility',category: Category.find_by_code('UC'))

Criterion.create!(code: 'S.1', name: 'Land Preservation', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.2', name: 'Water Body Preservation', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.3', name: 'Habitat Preservation', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.4', name: 'Vegetation', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.5', name: 'Desertification', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.6', name: 'Rainwater Runoff', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.7', name: 'Heat Island Effect', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.8', name: 'Adverse Wind Conditions', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.9', name: 'Noise Pollution', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.10', name: 'Light Pollution', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.11', name: 'Shading of Adjacent Properties', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.12', name: 'Parking Footprint', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.13', name: 'Shading', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.14', name: 'Illumination', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.15', name: 'Pathways', category: Category.find_by_code('S'))
Criterion.create!(code: 'S.16', name: 'Mixed Use', category: Category.find_by_code('S'))

Criterion.create!(code: 'E.1', name: 'Energy Demand Performance', category: Category.find_by_code('E'))
Criterion.create!(code: 'E.2', name: 'Energy Delivery Performance', category: Category.find_by_code('E'))
Criterion.create!(code: 'E.3', name: 'Fossil Fuel Conservation', category: Category.find_by_code('E'))
Criterion.create!(code: 'E.4', name: 'CO2 Emissions', category: Category.find_by_code('E'))
Criterion.create!(code: 'E.5', name: 'NOx, SOx, & Particulate Matter', category: Category.find_by_code('E'))

Criterion.create!(code: 'W.1', name: 'Water Consumption', category: Category.find_by_code('W'))

Criterion.create!(code: 'M.1', name: 'Regional Materials', category: Category.find_by_code('M'))
Criterion.create!(code: 'M.2', name: 'Responsible Sourcing of Materials', category: Category.find_by_code('M'))
Criterion.create!(code: 'M.3', name: 'Recycled Materials', category: Category.find_by_code('M'))
Criterion.create!(code: 'M.4', name: 'Materials Reuse', category: Category.find_by_code('M'))
Criterion.create!(code: 'M.5', name: 'Structure Reuse', category: Category.find_by_code('M'))
Criterion.create!(code: 'M.6', name: 'Design for Disassembly', category: Category.find_by_code('M'))

Criterion.create!(code: 'IE.1', name: 'Thermal Comfort', category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.2', name: 'Natural Ventilation', category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.3', name: 'Mechanical Ventilation', category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.4', name: 'Illumination Levels', category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.5', name: 'Daylight', category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.6', name: 'Glare Control', category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.7', name: 'Views', category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.8', name: 'Acoustic Quality', category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.9', name: 'Low-Emitting Materials', category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.10', name: 'Indoor Chemical & Pollutant Source Control', category: Category.find_by_code('IE'))

Criterion.create!(code: 'CE.1', name: 'Heritage & Cultural Identity', category: Category.find_by_code('CE'))
Criterion.create!(code: 'CE.2', name: 'Support of National Economy', category: Category.find_by_code('CE'))

Criterion.create!(code: 'MO.1', name: 'Commissioning Plan', category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.2', name: 'Organic Waste Management', category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.3', name: 'Recycling Management', category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.4', name: 'Leak Detection', category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.5', name: 'Energy & Water Use Sub-metering', category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.6', name: 'Automated Control System', category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.7', name: 'Hospitality Management Plan', category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.8', name: 'Sustainability Education & Awareness Plan', category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.9', name: 'Building Legacy', category: Category.find_by_code('MO'))

# Custom criteria for release 1
Category.create!(code: 'EX', name: 'Energy (existing buildings)', weight: 7)
Category.create!(code: 'WX', name: 'Water (existing buildings)', weight: 8)
Criterion.create!(code: 'EX.1', name: 'Energy consumption', category: Category.find_by_code('EX'))
Criterion.create!(code: 'WX.1', name: 'Water consumption', category: Category.find_by_code('WX'))

Certificate.create!(label: 'Letter of Conformance (currently not available)', certificate_type: :design_type, assessment_stage: :design_stage)
Certificate.create!(label: 'Final Design Certificate (currently not available)', certificate_type: :design_type, assessment_stage: :construction_stage)
Certificate.create!(label: 'Construction Certificate (currently not available)', certificate_type: :construction_type, assessment_stage: :construction_stage)
Certificate.create!(label: 'Operations Certificate', certificate_type: :operations_type, assessment_stage: :operations_stage)

Scheme.create!(label: 'Districts', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 0))
Scheme.create!(label: 'Districts', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 1))
Scheme.create!(label: 'Parks', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 0))
Scheme.create!(label: 'Parks', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 1))
Scheme.create!(label: 'Commercial', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 0))
Scheme.create!(label: 'Commercial', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 1))
Scheme.create!(label: 'Core + Shell', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 0))
Scheme.create!(label: 'Core + Shell', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 1))
Scheme.create!(label: 'Residential - Single', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 0))
Scheme.create!(label: 'Residential - Single', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 1))
Scheme.create!(label: 'Residential - Group', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 0))
Scheme.create!(label: 'Residential - Group', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 1))
Scheme.create!(label: 'Education', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 0))
Scheme.create!(label: 'Education', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 1))
Scheme.create!(label: 'Mosques', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 0))
Scheme.create!(label: 'Mosques', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 1))
Scheme.create!(label: 'Hotels', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 0))
Scheme.create!(label: 'Hotels', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 1))
Scheme.create!(label: 'Light Industry', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 0))
Scheme.create!(label: 'Light Industry', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 1))
Scheme.create!(label: 'Sports', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 0))
Scheme.create!(label: 'Sports', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 1))
Scheme.create!(label: 'Railways', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 0))
Scheme.create!(label: 'Railways', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 1))
Scheme.create!(label: 'Healthcare', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 0))
Scheme.create!(label: 'Healthcare', version: '3.0', certificate: Certificate.find_by(certificate_type: 0, assessment_stage: 1))
Scheme.create!(label: 'Construction', version: '3.0', certificate: Certificate.find_by(certificate_type: 1, assessment_stage: 1))
Scheme.create!(label: 'Operations', version: '3.0', certificate: Certificate.find_by(certificate_type: 2, assessment_stage: 2))
# todo: Scheme.create!(label: 'Workers\' Accommodation', version: '3.0')
# todo: Scheme.create!(label: 'Bespoke Schemes', version: '3.0')

operations_scheme = Scheme.find_by_label('Operations')
sc_op_ex1 = SchemeCriterion.create!(scheme: Scheme.find_by_label('Operations'), criterion: Criterion.find_by_code('EX.1'), weight: 5.2)
sc_op_wx1 = SchemeCriterion.create!(scheme: Scheme.find_by_label('Operations'), criterion: Criterion.find_by_code('WX.1'), weight: 16)
Score.create!(score: -1, description: 'kWh<sub>year</sub> &gt; 25000',                  scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: sc_op_ex1.criterion))
Score.create!(score: 0, description: '22500 &lt; kWh<sub>year</sub> &lte; 25000',        scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: sc_op_ex1.criterion))
Score.create!(score: 1, description: '20000  &lt; kWh<sub>year</sub> &lte; 22500',        scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: sc_op_ex1.criterion))
Score.create!(score: 2, description: '15000  &lt; kWh<sub>year</sub> &lte; 20000',        scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: sc_op_ex1.criterion))
Score.create!(score: 3, description: 'kWh<sub>year</sub> &lte; 15000',                  scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: sc_op_ex1.criterion))
Score.create!(score: -1, description: 'l<sub>year</sub> &gt; 5000',                 scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: sc_op_wx1.criterion))
Score.create!(score: 0, description: '4000  &lt; l<sub>year</sub> &lte; 5000',       scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: sc_op_wx1.criterion))
Score.create!(score: 1, description: '3000  &lt; l<sub>year</sub> &lte; 4000',       scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: sc_op_wx1.criterion))
Score.create!(score: 2, description: '2000  &lt; l<sub>year</sub> &lte; 3000',       scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: sc_op_wx1.criterion))
Score.create!(score: 3, description: 'l<sub>year</sub> &lte; 2000',                 scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: sc_op_wx1.criterion))
dummy_calculator = Calculator.create!(class_name: 'Calculator::Dummy')
req1 = Requirement.create!(reportable: dummy_calculator)
req2 = Requirement.create!(reportable: dummy_calculator)
SchemeCriterionRequirement.create!(scheme_criterion: sc_op_ex1, requirement: req1)
SchemeCriterionRequirement.create!(scheme_criterion: sc_op_wx1, requirement: req2)


# sc_op_e1 = SchemeCriterion.create!(scheme: Scheme.find_by_label('Operations'), criterion: Criterion.find_by_code('E.1'), weight: 5.2)
# sc_op_e2 = SchemeCriterion.create!(scheme: Scheme.find_by_label('Operations'), criterion: Criterion.find_by_code('E.2'), weight: 5.2)
# sc_op_e3 = SchemeCriterion.create!(scheme: Scheme.find_by_label('Operations'), criterion: Criterion.find_by_code('E.3'), weight: 3.64)
# sc_op_e4 = SchemeCriterion.create!(scheme: Scheme.find_by_label('Operations'), criterion: Criterion.find_by_code('E.4'), weight: 4.55)
# sc_op_e5 = SchemeCriterion.create!(scheme: Scheme.find_by_label('Operations'), criterion: Criterion.find_by_code('E.5'), weight: 5.42)
# sc_op_e6 = SchemeCriterion.create!(scheme: Scheme.find_by_label('Operations'), criterion: Criterion.find_by_code('W.1'), weight: 16)
#
# operations_scheme = Scheme.find_by_label('Operations')
# criterion_e1 = Criterion.find_by_code('E.1')
# criterion_e2 = Criterion.find_by_code('E.2')
# criterion_e3 = Criterion.find_by_code('E.3')
# criterion_e4 = Criterion.find_by_code('E.4')
# criterion_e5 = Criterion.find_by_code('E.5')
# criterion_w1 = Criterion.find_by_code('W.1')
#
# Score.create!(score: -1, description: 'EPC<sub>nd</sub> &gt; 1.0',                  scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e1))
# Score.create!(score: 0, description: '0.8  &lt; EPC<sub>nd</sub> &lte; 1.0',        scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e1))
# Score.create!(score: 1, description: '0.7  &lt; EPC<sub>nd</sub> &lte; 0.8',        scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e1))
# Score.create!(score: 2, description: '0.6  &lt; EPC<sub>nd</sub> &lte; 0.7',        scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e1))
# Score.create!(score: 3, description: 'EPC<sub>nd</sub> &lte; 0.6',                  scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e1))
# Score.create!(score: -1, description: 'EPC<sub>del</sub> &gt; 1.0',                 scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e2))
# Score.create!(score: 0, description: '0.8  &lt; EPC<sub>del</sub> &lte; 1.0',       scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e2))
# Score.create!(score: 1, description: '0.7  &lt; EPC<sub>del</sub> &lte; 0.8',       scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e2))
# Score.create!(score: 2, description: '0.6  &lt; EPC<sub>del</sub> &lte; 0.7',       scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e2))
# Score.create!(score: 3, description: 'EPC<sub>del</sub> &lte; 0.6',                 scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e2))
# Score.create!(score: -1, description: 'EPC<sub>p</sub> &gt; 1.0',                   scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e3))
# Score.create!(score: 0, description: '0.8  &lt; EPC<sub>p</sub> &lte; 1.0',         scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e3))
# Score.create!(score: 1, description: '0.7  &lt; EPC<sub>p</sub> &lte; 0.8',         scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e3))
# Score.create!(score: 2, description: '0.6  &lt; EPC<sub>p</sub> &lte; 0.7',         scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e3))
# Score.create!(score: 3, description: 'EPC<sub>p</sub> &lte; 0.6',                   scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e3))
# Score.create!(score: -1, description: 'EPC<sub>CO2</sub> &gt; 1.0',                 scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e4))
# Score.create!(score: 0, description: '0.8  &lt; EPC<sub>CO2</sub> &lte; 1.0',       scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e4))
# Score.create!(score: 1, description: '0.7  &lt; EPC<sub>CO2</sub> &lte; 0.8',       scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e4))
# Score.create!(score: 2, description: '0.6  &lt; EPC<sub>CO2</sub> &lte; 0.7',       scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e4))
# Score.create!(score: 3, description: 'EPC<sub>co2</sub> &lte; 0.6',                 scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e4))
# Score.create!(score: -1, description: 'EPC<sub>NOx-SOx</sub> &gt; 1.0',             scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e5))
# Score.create!(score: 0, description: '0.8  &lt; EPC<sub>NOx-SOx</sub> &lte; 1.0',   scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e5))
# Score.create!(score: 1, description: '0.7  &lt; EPC<sub>NOx-SOx</sub> &lte; 0.8',   scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e5))
# Score.create!(score: 2, description: '0.6  &lt; EPC<sub>NOx-SOx</sub> &lte; 0.7',   scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e5))
# Score.create!(score: 3, description: 'EPC<sub>NOx-SOx</sub> &lte; 0.6',             scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_e5))
# Score.create!(score: -1, description: 'X &gt; 1.0',                                 scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_w1))
# Score.create!(score: 0, description: '0.87  &lt; X &lte; 1.0',                      scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_w1))
# Score.create!(score: 1, description: '0.73  &lt; X &lte; 0.87',                     scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_w1))
# Score.create!(score: 2, description: '0.6  &lt; X &lte; 0.73',                      scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_w1))
# Score.create!(score: 3, description: 'X &lte; 0.6',                                 scheme_criterion: SchemeCriterion.find_by(scheme: operations_scheme, criterion: criterion_w1))
