# Scheme titles
Scheme.where(
    name: "Interiors"
  ).update_all(
    name: "Fitout"
  )

# Development Type titles
DevelopmentType.where(
    name: "Single Zone, Interiors"
  ).update_all(
    name: "Single Zone, Fitout"
  )

# Change scheme name in licence's Allowed Schemes
Licence.where(
  licence_type: 'ServiceProviderLicence',
  display_name: 'GSAS DESIGN & BUILD, TYPE 1 - COMMON SCHEMES',
  display_weight: 1,
  title: 'TYPE 1',
  description: 'GSAS Design & Build Service Provider',
  certificate_type: Certificate.certificate_types[:design_type],
  schemes: ['Commercial', 'Offices', 'Residential', 'Residential - Single', 'Education', 'Mosques', 'Hospitality', 'Homes', 'Light Industry', 'Interiors', 'Renovations', 'Camps & Festival Sites', 'Parks']
).update(
  schemes: ['Commercial', 'Offices', 'Residential', 'Residential - Single', 'Education', 'Mosques', 'Hospitality', 'Homes', 'Light Industry', 'Fitout', 'Renovations', 'Camps & Festival Sites', 'Parks']
)

