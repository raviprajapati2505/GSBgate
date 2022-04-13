# Licences for Service Providers
# D&B
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'GSAS DESIGN & BUILD, TYPE 1 - COMMON SCHEMES',
  display_weight: 1,
  title: 'TYPE 1',
  description: 'GSAS Design & Build Service Provider',
  certificate_type: Certificate.certificate_types[:design_type],
  schemes: ['Commercial', 'Offices', 'Residential', 'Residential - Single', 'Education', 'Mosques', 'Hospitality', 'Homes', 'Light Industry', 'Interiors', 'Renovations', 'Camps & Festival Sites', 'Parks']
)
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'GSAS DESIGN & BUILD, TYPE 2 - DISTRICTS',
  display_weight: 2,
  title: 'TYPE 2',
  description: 'GSAS Design & Build Service Provider',
  certificate_type: Certificate.certificate_types[:design_type],
  schemes: ['Commercial']
)
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'GSAS DESIGN & BUILD, TYPE 3 - ENERGY CENTERS',
  display_weight: 3,
  title: 'TYPE 3',
  description: 'GSAS Design & Build Service Provider',
  certificate_type: Certificate.certificate_types[:design_type],
  schemes: ['Energy Centers']
)
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'GSAS DESIGN & BUILD, TYPE 4 - HEALTHCARE',
  display_weight: 4,
  title: 'TYPE 4',
  description: 'GSAS Design & Build Service Provider',
  certificate_type: Certificate.certificate_types[:design_type],
  schemes: ['Healthcare']
)
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'GSAS DESIGN & BUILD, TYPE 5 - RAILWAYS',
  display_weight: 5,
  title: 'TYPE 5',
  description: 'GSAS Design & Build Service Provider',
  certificate_type: Certificate.certificate_types[:design_type],
  schemes: ['Railways']
)
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'GSAS DESIGN & BUILD, TYPE 6 - SPORTS',
  display_weight: 6,
  title: 'TYPE 6',
  description: 'GSAS Design & Build Service Provider',
  certificate_type: Certificate.certificate_types[:design_type],
  schemes: ['Sports']
)

# CM
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'GSAS CONSTRUCTION MANAGEMENT',
  display_weight: 7,
  title: 'GSAS CONSTRUCTION MANAGEMENT',
  description: 'GSAS Construction Management Service Provider',
  certificate_type: Certificate.certificate_types[:construction_type],
  schemes: ['Construction Site']
)

# OP
Licence.find_or_create_by!(
  licence_type: 'ServiceProviderLicence',
  display_name: 'GSAS OPERATIONS',
  display_weight: 8,
  title: 'GSAS OPERATIONS',
  description: 'GSAS Operation Service Provider',
  certificate_type: Certificate.certificate_types[:operations_type],
  schemes: ['Premium Scheme', 'Standard Scheme', 'Healthy Building Mark', 'Energy Neutral Mark']
)

# Licences for Certified Professional
# D&B - CGP
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'GSAS CGP DESIGN & BUILD, TYPE 1 - MEMBERSHIP',
  display_weight: 9,
  title: 'TYPE 1 - CGP',
  description: 'GSAS Design & Build Certified Green Professional',
  certificate_type: Certificate.certificate_types[:design_type]
)

Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'GSAS CGP DESIGN & BUILD, TYPE 2 - MEMBERSHIP',
  display_weight: 10,
  title: 'TYPE 2 - CGP',
  description: 'GSAS Design & Build Certified Green Professional',
  certificate_type: Certificate.certificate_types[:design_type]
)

Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'GSAS CGP DESIGN & BUILD, TYPE 3 - MEMBERSHIP',
  display_weight: 11,
  title: 'TYPE 3 - CGP',
  description: 'GSAS Design & Build Certified Green Professional',
  certificate_type: Certificate.certificate_types[:design_type],
  applicability: Licence.applicabilities[:check_list]
)

# CM - CGP
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'GSAS CGP CONSTRUCTION MANAGEMENT',
  display_weight: 12,
  title: 'GSAS CONSTRUCTION MANAGEMENT - CGP',
  description: 'GSAS Construction Management Certified Green Professional',
  certificate_type: Certificate.certificate_types[:construction_type]
)

# OP - CGP
Licence.find_or_create_by!(
  licence_type: 'CgpLicence',
  display_name: 'GSAS CGP OPERATIONS',
  display_weight: 13,
  title: 'GSAS OPERATIONS - CGP',
  description: 'GSAS Operation Certified Green Professional',
  certificate_type: Certificate.certificate_types[:operations_type]
)

# D&B - CEP
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'GSAS CEP DESIGN & BUILD, TYPE 1 - MEMBERSHIP',
  display_weight: 14,
  title: 'TYPE 1 - CEP',
  description: 'GSAS Design & Build Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:design_type],
  applicability: Licence.applicabilities[:check_list]
)

# CM - CGP
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'GSAS CEP CONSTRUCTION MANAGEMENT',
  display_weight: 15,
  title: 'GSAS CONSTRUCTION MANAGEMENT - CEP',
  description: 'GSAS Construction Management Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:construction_type]
)

# OP - CGP
Licence.find_or_create_by!(
  licence_type: 'CepLicence',
  display_name: 'GSAS CEP OPERATIONS',
  display_weight: 16,
  title: 'GSAS OPERATIONS - CEP',
  description: 'GSAS Operation Certified Energy Professional',
  certificate_type: Certificate.certificate_types[:operations_type]
)