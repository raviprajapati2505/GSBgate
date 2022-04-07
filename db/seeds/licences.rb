# Licences for Service Providers
# D&B
ServiceProviderLicence.find_or_create_by(
  display_name: 'TYPE 1 - COMMON SCHEMES',
  title: 'TYPE 1',
  description: 'GSAS DESIGN & BUILD SERVICE PROVIDER',
  certificate_type: Certificate.certificate_types[:design_type],
  schemes: ['Commercial', 'Offices', 'Residential', 'Residential - Single', 'Education', 'Mosques', 'Hospitality', 'Homes', 'Light Industry', 'Interiors', 'Renovations', 'Camps & Festival Sites', 'Parks']
)
ServiceProviderLicence.find_or_create_by(
  display_name: 'TYPE 2 - DISTRICTS',
  title: 'TYPE 2',
  description: 'GSAS DESIGN & BUILD SERVICE PROVIDER',
  certificate_type: Certificate.certificate_types[:design_type],
  schemes: ['Commercial']
)
ServiceProviderLicence.find_or_create_by(
  display_name: ' TYPE 3 - ENERGY CENTERS',
  title: 'TYPE 3',
  description: 'GSAS DESIGN & BUILD SERVICE PROVIDER',
  certificate_type: Certificate.certificate_types[:design_type],
  schemes: ['Energy Centers']
)
ServiceProviderLicence.find_or_create_by(
  display_name: 'TYPE 4 - HEALTHCARE',
  title: 'TYPE 4',
  description: 'GSAS DESIGN & BUILD SERVICE PROVIDER',
  certificate_type: Certificate.certificate_types[:design_type],
  schemes: ['Healthcare']
)
ServiceProviderLicence.find_or_create_by(
  display_name: 'TYPE 5 - RAILWAYS',
  title: 'TYPE 5',
  description: 'GSAS DESIGN & BUILD SERVICE PROVIDER',
  certificate_type: Certificate.certificate_types[:design_type],
  schemes: ['Railways']
)
ServiceProviderLicence.find_or_create_by(
  display_name: 'TYPE 6 - SPORTS',
  title: 'TYPE 6',
  description: 'GSAS DESIGN & BUILD SERVICE PROVIDER',
  certificate_type: Certificate.certificate_types[:design_type],
  schemes: ['Sports']
)

# CM
ServiceProviderLicence.find_or_create_by(
  display_name: 'GSAS CONSTRUCTION MANAGEMENT',
  title: 'GSAS CONSTRUCTION MANAGEMENT',
  description: 'GSAS CONSTRUCTION MANAGEMENT SERVICE PROVIDER',
  certificate_type: Certificate.certificate_types[:construction_type],
  schemes: ['Construction Site']
)

# OP
ServiceProviderLicence.find_or_create_by(
  display_name: 'GSAS OPERATIONS',
  title: 'GSAS OPERATIONS',
  description: 'GSAS OPERATIONS SERVICE PROVIDER',
  certificate_type: Certificate.certificate_types[:operations_type],
  schemes: ['Premium Scheme', 'Standard Scheme', 'Healthy Building Mark', 'Energy Neutral Mark']
)

# Licences for Certified Professional
# D&B - CGP
CpLicence.find_or_create_by(
  display_name: 'TYPE 1 - MEMBERSHIP',
  title: 'TYPE 1 - CGP',
  description: 'GSAS DESIGN & BUILD CERTIFIED GREEN PROFESSIONAL',
  certificate_type: Certificate.certificate_types[:design_type]
)

CpLicence.find_or_create_by(
  display_name: 'TYPE 2 - MEMBERSHIP',
  title: 'TYPE 2 - CGP',
  description: 'GSAS DESIGN & BUILD CERTIFIED GREEN PROFESSIONAL',
  certificate_type: Certificate.certificate_types[:design_type]
)

CpLicence.find_or_create_by(
  display_name: 'TYPE 3 - MEMBERSHIP',
  title: 'TYPE 3 - CGP',
  description: 'GSAS DESIGN & BUILD CERTIFIED GREEN PROFESSIONAL',
  certificate_type: Certificate.certificate_types[:design_type],
  applicability: Licence.applicabilities[:check_list]
)

# CM - CGP
CpLicence.find_or_create_by(
  display_name: 'GSAS CONSTRUCTION MANAGEMENT',
  title: 'GSAS CONSTRUCTION MANAGEMENT - CGP',
  description: 'GSAS CONSTRUCTION MANAGEMENT CERTIFIED GREEN PROFESSIONAL',
  certificate_type: Certificate.certificate_types[:construction_type]
)

# OP - CGP
CpLicence.find_or_create_by(
  display_name: 'GSAS OPERATIONS',
  title: 'GSAS OPERATIONS - CGP',
  description: 'GSAS OPERATIONS CERTIFIED GREEN PROFESSIONAL',
  certificate_type: Certificate.certificate_types[:operations_type]
)