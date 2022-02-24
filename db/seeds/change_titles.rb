# Add/Edit title of Owners
Owner.destroy_all

Owner.find_or_create_by!(name: 'Aspire Zone Foundation (AZF)', governmental: true)
Owner.find_or_create_by!(name: 'Barwa', private_owner: true)
Owner.find_or_create_by!(name: 'Hamad Medical Corporation (HMC)', governmental: true)
Owner.find_or_create_by!(name: 'Internal Security Force (Lekhwiya)', governmental: true)
Owner.find_or_create_by!(name: 'Katara Hospitality', private_owner: true)
Owner.find_or_create_by!(name: 'Milaha Maritime & Logistics', private_owner: true)
Owner.find_or_create_by!(name: 'Ministry of Commerce and Industry', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Communications and Information Technology', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Culture', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Defense', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Education and Higher Education', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Endowments and Islamic Affairs', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Environment and Climate Change', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Finance', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Interior', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Justice', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Labor', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Municipality', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Public Health', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Social Development and Family', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Sports and Youth', governmental: true)
Owner.find_or_create_by!(name: 'Ministry of Transport', governmental: true)
Owner.find_or_create_by!(name: 'New Port Project (NPP)', governmental: true)
Owner.find_or_create_by!(name: 'Primary Health Care Corporation (PHCC)', private_owner: true)
Owner.find_or_create_by!(name: 'Private Sector', private_owner: true)
Owner.find_or_create_by!(name: 'Public Works Authority (ASHGHAL)', governmental: true)
Owner.find_or_create_by!(name: 'Qatar Company for Airport Operations & Management (MATAR)', governmental: true)
Owner.find_or_create_by!(name: 'Qatar Economic Zone Company (MANATEQ)', governmental: true)
Owner.find_or_create_by!(name: 'Qatar Energy (QE)', governmental: true)
Owner.find_or_create_by!(name: 'Qatar Foundation (QF)', governmental: true)
Owner.find_or_create_by!(name: 'Qatar General Electricity & Water Corporation (KAHRAMAA)', governmental: true)
Owner.find_or_create_by!(name: 'Qatar Museums (QM)', governmental: true)
Owner.find_or_create_by!(name: 'Qatar Rail (QR)', governmental: true)
Owner.find_or_create_by!(name: 'Qatar University (QU)', governmental: true)
Owner.find_or_create_by!(name: 'Qatari Diar', private_developer: true)
Owner.find_or_create_by!(name: 'QETAIFAN Projects', governmental: true)
Owner.find_or_create_by!(name: 'QTerminals', governmental: true)
Owner.find_or_create_by!(name: 'Supreme Committee for Delivery & Legacy (SC)', governmental: true)

# Edit locations
Location.find_by(country: "United Arab Emirates")&.update(list: ["Abu Dhabi", "Ajman", "Dubai", "Fujairah"])

# Update country of projects.
Project.where('code ILIKE ?', '%-QA-%').update_all(country: 'Qatar')

#######################################################################################################################################

# CM document_type title
DevelopmentType.where(name: "Single use construction").update_all(name: "Construction Site")

# OP document_type title changes
DevelopmentType.where(name: "Single use operations", certificate_id: Certificate.where(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]).ids).update_all(name: "Single Use Building")
DevelopmentType.where(name: "Single Use", certificate_id: Certificate.where(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]).ids).update_all(name: "Single Use Building")
DevelopmentType.where(name: "Mixed Use", certificate_id: Certificate.where(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]).ids).update_all(name: "Mixed Use Building")
DevelopmentType.where(name: "Single Zone (Interiors)", certificate_id: Certificate.where(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]).ids).update_all(name: "Single Zone, Interiors")
DevelopmentType.where(name: "Neighbourhood (mixed development)", certificate_id: Certificate.where(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]).ids).update_all(name: "Neighborhood")
DevelopmentType.find_or_create_by!(display_weight: 50, certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage], gsas_version: "2019"), name: 'District', mixable: false)
DevelopmentType.find_or_create_by!(display_weight: 60, certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage], gsas_version: "2019"), name: 'Park', mixable: false)

# D&B document_type title changes

# Certificate_ids [3, 4, 5, 6, 17, 18] with display_weight: 10 for all
DevelopmentType.where(name: 'Single use building, new').update_all(name: 'Single Use Building')
# Certificate_ids [3, 4, 5, 6, 17, 18] with display_weight: 50 for all 
DevelopmentType.where(name: 'Single use building, existing').update_all(name: 'Single Use Building')
# Certificate_ids [3, 4, 5, 6, 17, 18] with display_weight: 20 for all 
DevelopmentType.where(name: 'Mixed use building').update_all(name: 'Mixed Use Building')
# Certificate_ids [3, 4, 5, 6, 17, 18] with display_weight: 60 for all 
DevelopmentType.where(name: 'Districts').update_all(name: 'District')
# Certificate_ids [17, 70] with display_weight: 70 for all 
DevelopmentType.where(name: 'Parks').update_all(name: 'Park')
# Certificate_ids [3, 4, 5, 6, 17, 18] with display_weight: 40 for all 
DevelopmentType.where(name: 'Neighbourhood in stages (mixed development in stages)').update_all(name: 'Neighborhood')
# Certificate_ids [3, 4, 5, 6, 17, 18, 16/DW:40] with display_weight: 30 for all 
DevelopmentType.where(name: 'Neighbourhood (mixed development)').update_all(name: 'Neighborhood')

# projects building type group & scheme renaming
BuildingTypeGroup.where(name: 'Districts').update_all(name: 'District')
BuildingTypeGroup.where(name: 'Parks').update_all(name: 'Park')
Scheme.where(name: "Districts").update_all(name: "District")
Scheme.where(name: "Parks").update_all(name: "Park")
Scheme.where(name: "Construction").update_all(name: "Construction Site")

# # ALl D&B projects have building_type_group: 'district' but certification path development type is something else
# CertificationPath.joins(:project).where(projects: { building_type_group: BuildingTypeGroup.find_by(name: "District"), certificate_type: Certificate.certificate_types[:design_type] }, development_type_id: DevelopmentType.where(name: 'Single Use Building')).update_all(development_type_id: 28)
