# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Add admin user
User.create!(email: 'admin@vito.be', password: 'gsas-secret', password_confirmation: 'gsas-secret', role: :admin)

ProjectStatus.create!(name: 'Certification in review')
ProjectStatus.create!(name: 'GSAS certified')
ProjectStatus.create!(name: 'Preliminary stage pending')
ProjectStatus.create!(name: 'Suspended')

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
Criterion.create!(code: 'UC.1', name: 'Proximity to Infrastructure', score_min: 0, score_max: 3, category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.2', name: 'Load on Local Traffic Conditions', score_min: 0, score_max: 3, category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.3', name: 'Public Transportation', score_min: 0, score_max: 3, category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.4', name: 'Private Transportation', score_min: 0, score_max: 3, category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.5', name: 'Sewer & Waterway Contamination', score_min: 0, score_max: 3, category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.6', name: 'Acoustic Conditions', score_min: 0, score_max: 3, category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.7', name: 'Proximity to Amenities', score_min: 0, score_max: 3, category: Category.find_by_code('UC'))
Criterion.create!(code: 'UC.8', name: 'Accessibility', score_min: 0, score_max: 3, category: Category.find_by_code('UC'))

Criterion.create!(code: 'S.1', name: 'Land Preservation', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.2', name: 'Water Body Preservation', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.3', name: 'Habitat Preservation', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.4', name: 'Vegetation', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.5', name: 'Desertification', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.6', name: 'Rainwater Runoff', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.7', name: 'Heat Island Effect', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.8', name: 'Adverse Wind Conditions', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.9', name: 'Noise Pollution', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.10', name: 'Light Pollution', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.11', name: 'Shading of Adjacent Properties', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.12', name: 'Parking Footprint', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.13', name: 'Shading', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.14', name: 'Illumination', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.15', name: 'Pathways', score_min: -1, score_max: 3, category: Category.find_by_code('S'))
Criterion.create!(code: 'S.16', name: 'Mixed Use', score_min: -1, score_max: 3, category: Category.find_by_code('S'))

Criterion.create!(code: 'E.1', name: 'Energy Demand Performance', score_min: -1, score_max: 3, category: Category.find_by_code('E'))
Criterion.create!(code: 'E.2', name: 'Energy Delivery Performance', score_min: -1, score_max: 3, category: Category.find_by_code('E'))
Criterion.create!(code: 'E.3', name: 'Fossil Fuel Conservation', score_min: -1, score_max: 3, category: Category.find_by_code('E'))
Criterion.create!(code: 'E.4', name: 'CO2 Emissions', score_min: -1, score_max: 3, category: Category.find_by_code('E'))
Criterion.create!(code: 'E.5', name: 'NOx, SOx, & Particulate Matter', score_min: -1, score_max: 3, category: Category.find_by_code('E'))

Criterion.create!(code: 'W.1', name: 'Water Consumption', score_min: -1, score_max: 3, category: Category.find_by_code('W'))

Criterion.create!(code: 'M.1', name: 'Regional Materials', score_min: -1, score_max: 3, category: Category.find_by_code('M'))
Criterion.create!(code: 'M.2', name: 'Responsible Sourcing of Materials', score_min: -1, score_max: 3, category: Category.find_by_code('M'))
Criterion.create!(code: 'M.3', name: 'Recycled Materials', score_min: -1, score_max: 3, category: Category.find_by_code('M'))
Criterion.create!(code: 'M.4', name: 'Materials Reuse', score_min: -1, score_max: 3, category: Category.find_by_code('M'))
Criterion.create!(code: 'M.5', name: 'Structure Reuse', score_min: -1, score_max: 3, category: Category.find_by_code('M'))
Criterion.create!(code: 'M.6', name: 'Design for Disassembly', score_min: -1, score_max: 3, category: Category.find_by_code('M'))

Criterion.create!(code: 'IE.1', name: 'Thermal Comfort', score_min: -1, score_max: 3, category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.2', name: 'Natural Ventilation', score_min: -1, score_max: 3, category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.3', name: 'Mechanical Ventilation', score_min: -1, score_max: 3, category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.4', name: 'Illumination Levels', score_min: -1, score_max: 3, category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.5', name: 'Daylight', score_min: -1, score_max: 3, category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.6', name: 'Glare Control', score_min: -1, score_max: 3, category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.7', name: 'Views', score_min: -1, score_max: 3, category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.8', name: 'Acoustic Quality', score_min: -1, score_max: 3, category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.9', name: 'Low-Emitting Materials', score_min: -1, score_max: 3, category: Category.find_by_code('IE'))
Criterion.create!(code: 'IE.10', name: 'Indoor Chemical & Pollutant Source Control', score_min: -1, score_max: 3, category: Category.find_by_code('IE'))

Criterion.create!(code: 'CE.1', name: 'Heritage & Cultural Identity', score_min: -1, score_max: 3, category: Category.find_by_code('CE'))
Criterion.create!(code: 'CE.2', name: 'Support of National Economy', score_min: -1, score_max: 3, category: Category.find_by_code('CE'))

Criterion.create!(code: 'MO.1', name: 'Commissioning Plan', score_min: 0, score_max: 3, category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.2', name: 'Organic Waste Management', score_min: 0, score_max: 3, category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.3', name: 'Recycling Management', score_min: 0, score_max: 3, category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.4', name: 'Leak Detection', score_min: 0, score_max: 3, category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.5', name: 'Energy & Water Use Sub-metering', score_min: 0, score_max: 3, category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.6', name: 'Automated Control System', score_min: 0, score_max: 3, category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.7', name: 'Hospitality Management Plan', score_min: 0, score_max: 3, category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.8', name: 'Sustainability Education & Awareness Plan', score_min: 0, score_max: 3, category: Category.find_by_code('MO'))
Criterion.create!(code: 'MO.9', name: 'Building Legacy', score_min: 0, score_max: 3, category: Category.find_by_code('MO'))