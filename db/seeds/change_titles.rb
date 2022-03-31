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
Project.where("country ILIKE 'TURKEY'").update_all(country: 'Turkey')

#######################################################################################################################################

# CM document_type title
DevelopmentType.where(name: "Single use construction").update_all(name: "Construction Site")

# OP document_type title changes
DevelopmentType.where(name: "Single use operations", certificate_id: Certificate.where(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]).ids).update_all(name: "Single Use Building")
DevelopmentType.where(name: "Single Use", certificate_id: Certificate.where(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]).ids).update_all(name: "Single Use Building")
DevelopmentType.where(name: "Single Zone (Interiors)", certificate_id: Certificate.where(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage]).ids).update_all(name: "Single Zone, Interiors")
DevelopmentType.find_or_create_by!(display_weight: 50, certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage], gsas_version: "2019"), name: 'Districts', mixable: false)
DevelopmentType.find_or_create_by!(display_weight: 60, certificate: Certificate.find_by(certificate_type: Certificate.certificate_types[:operations_type], assessment_stage: Certificate.assessment_stages[:operations_stage], gsas_version: "2019"), name: 'Parks', mixable: false)

# D&B document_type title changes

# Certificate_ids [3, 4, 5, 6, 17, 18] with display_weight: 10 for all
DevelopmentType.where(name: 'Single use building, new').update_all(name: 'Single Use Building')
# Certificate_ids [3, 4, 5, 6, 17, 18] with display_weight: 50 for all 
DevelopmentType.where(name: 'Single use building, existing').update_all(name: 'Single Use Building')
# Certificate_ids [3, 4, 5, 6, 17, 18] with display_weight: 20 for all 
DevelopmentType.where(name: 'Mixed use building').update_all(name: 'Mixed Use')
# Certificate_ids [3, 4, 5, 6, 17, 18] with display_weight: 40 for all 
DevelopmentType.where(name: 'Neighbourhood in stages (mixed development in stages)').update_all(name: 'Neighborhoods')
# Certificate_ids [3, 4, 5, 6, 17, 18, 16/DW:40] with display_weight: 30 for all 
DevelopmentType.where(name: 'Neighbourhood (mixed development)').update_all(name: 'Neighborhoods')

# projects building type group & scheme renaming
Scheme.where(name: "Neighborhood").update_all(name: "Neighborhoods")
Scheme.where(name: "Construction").update_all(name: "Construction Site")

# Commercial (v2.0, v2.1) scheme ids [1, 2, 3, 4, 5, 6, 7, 11, 76]
Scheme.where(name: "Commercial", gsas_version: ["2.0", "2.1"]).update_all(name: "Offices")
# Core + Shell (v2.1) scheme id 11
Scheme.where(name: "Core + Shell", gsas_version: "2.1").update_all(name: "Commercial")
# Residential - Group (v2.0, v2.1) scheme ids [52, 53, 54, 55, 56, 57, 58, 84]
Scheme.where(name: "Residential - Group", gsas_version: ["2.0", "2.1"]).update_all(name: "Residential")
# Residential - Single (v2.1) scheme ids [60, 61, 63]
Scheme.where(name: "Residential - Single", gsas_version: "2.1").update_all(name: "Residential")
# Hotels (v2.1) scheme ids [26, 27, 29, 79]
Scheme.where(name: "Hotels", gsas_version: "2.1").update_all(name: "Hospitality")
# Offices-OP (v2.1) scheme ids [3]
Scheme.where(name: "Offices", certificate_type: 2, gsas_version: "2.1").update_all(name: "Standard Scheme")

# Set mixable true to all "Mixed Use" development type.
DevelopmentType.where(name: "Mixed Use", mixable: false).update_all(mixable: true)

# Update districts for following projects
project_codes = ["PD-QA-0247-0248", "PD-QA-0247-0248", "PD-QA-0712-0716", "PD-QA-0712-0716", "PD-QA-0940-0945", "PD-QA-0086-0086", "PD-QA-0304-0305", "PD-QA-0275-0276", "PD-QA-0275-0276"]
Project.where(code: project_codes).update_all(district: "Lusail")

project_codes = ["PD-QA-0466-0468", "PD-QA-0466-0468", "PD-QA-0154-0154", "PD-QA-0155-0155", "PD-QA-0300-0301", "PD-QA-0300-0301", "PD-QA-0506-0508", "PD-QA-0506-0508", "PD-QA-0685-0688", "PD-QA-0188-0189", "PD-QA-0908-0913", "PD-QA-0741-0745", "PD-QA-0844-0849", "PD-QA-0744-0748", "PD-QA-0613-0615", "PD-QA-0272-0273", "PD-QA-0910-0915", "PD-QA-0720-0724", "PD-QA-0934-0939", "PD-QA-0191-0192", "PD-QA-0775-0779", "PD-QA-0531-0533", "PD-QA-0319-0320", "PD-QA-0324-0325", "PD-QA-0324-0325", "PD-QA-0212-0213", "PD-QA-0190-0191", "PD-QA-0721-0725", "PD-QA-0299-0300", "PD-QA-0299-0300"]
Project.where(code: project_codes).update_all(district: "Lusail- Al Erkyah")

project_codes = ["PD-QA-0047-0047", "PD-QA-0269-0270", "PD-QA-0479-0481", "PD-QA-0480-0482", "PD-QA-0545-0547", "PD-QA-0592-0594", "PD-QA-0617-0619", "PD-QA-0644-0647", "PD-QA-0645-0648", "PD-QA-0681-0684", "PD-QA-0688-0691", "PD-QA-0688-0691", "PD-QA-0759-0763"]
Project.where(code: project_codes).update_all(district: "Lusail- Al Kharaej")

project_codes = ["PD-QA-0882-0887", "PD-QA-0875-0880", "PD-QA-0883-0888", "PD-QA-0884-0889", "PD-QA-0886-0891", "PD-QA-0887-0892", "PD-QA-0892-0897", "PD-QA-0888-0893", "PD-QA-0889-0894", "PD-QA-0877-0882", "PD-QA-0878-0883", "PD-QA-0879-0884", "PD-QA-0880-0885", "PD-QA-0881-0886", "PD-QA-0890-0895", "PD-QA-0891-0896", "PD-QA-0885-0890", "PD-QA-0876-0881", "PD-QA-0858-0863", "PD-QA-0859-0864", "PD-QA-0860-0865", "PD-QA-0861-0866"]
Project.where(code: project_codes).update_all(district: "Lusail- Boulevard_COM")

project_codes = ["PD-QA-0813-0818", "PD-QA-0819-0824", "PD-QA-0819-0824", "PD-QA-0933-0938", "PD-QA-0937-0942", "PD-QA-0005-0005", "PD-QA-0308-0309", "PD-QA-0152-0152", "PD-QA-0623-0625", "PD-QA-0216-0217", "PD-QA-0130-0130", "PD-QA-0261-0262", "PD-QA-0693-0696", "PD-QA-0693-0696", "PD-QA-0485-0487", "PD-QA-0486-0488", "PD-QA-0128-0128", "PD-QA-0128-0128", "PD-QA-0199-0200", "PD-QA-0320-0321", "PD-QA-0241-0242", "PD-QA-0179-0179", "PD-QA-0591-0593", "PD-QA-0766-0770", "PD-QA-0560-0562", "PD-QA-0560-0562", "PD-QA-0254-0255", "PD-QA-0309-0310", "PD-QA-0529-0531", "PD-QA-0178-0178", "PD-QA-0582-0584", "PD-QA-0582-0584", "PD-QA-0249-0250", "PD-QA-0270-0271", "PD-QA-0829-0834", "PD-QA-0829-0834", "PD-QA-0921-0926"]
Project.where(code: project_codes).update_all(district: "Lusail- ECQ_1")

project_codes = ["PD-QA-0838-0843", "PD-QA-0071-0071", "PD-QA-0217-0218", "PD-QA-0055-0055", "PD-QA-0607-0609", "PD-QA-0609-0611", "PD-QA-0936-0941", "PD-QA-0071-0071", "PD-QA-0097-0097", "PD-QA-0103-0103", "PD-QA-0103-0103"]
Project.where(code: project_codes).update_all(district: "Lusail- Entertainment City")

Project.where(code: ["PD-QA-0599-0601"]).update_all(district: "Lusail- Entertainment Island")

project_codes = ["PD-QA-0139-0139", "PD-QA-0289-0290", "PD-QA-0135-0135", "PD-QA-0135-0135", "PD-QA-0132-0132", "PD-QA-0132-0132", "PD-QA-0058-0058", "PD-QA-0058-0058", "PD-QA-0051-0051", "PD-QA-0051-0051", "PD-QA-0526-0528", "PD-QA-0526-0528", "PD-QA-0443-0445", "PD-QA-0627-0629", "PD-QA-0293-0294", "PD-QA-0920-0925", "PD-QA-0142-0142", "PD-QA-0158-0158", "PD-QA-0177-0177", "PD-QA-0794-0799", "PD-QA-0176-0176", "PD-QA-0925-0930", "PD-QA-0284-0285", "PD-QA-0284-0285", "PD-QA-0460-0462", "PD-QA-0140-0140", "PD-QA-0294-0295", "PD-QA-0141-0141", "PD-QA-0150-0150", "PD-QA-0151-0151", "PD-QA-0595-0597", "PD-QA-0595-0597", "PD-QA-0146-0146", "PD-QA-0146-0146", "PD-QA-0782-0786", "PD-QA-0782-0786", "PD-QA-0432-0434", "PD-QA-0159-0159", "PD-QA-0159-0159", "PD-QA-0161-0161", "PD-QA-0162-0162", "PD-QA-0163-0163", "PD-QA-0164-0164", "PD-QA-0164-0164", "PD-QA-0165-0165", "PD-QA-0166-0166", "PD-QA-0166-0166", "PD-QA-0167-0167", "PD-QA-0167-0167", "PD-QA-0160-0160", "PD-QA-0160-0160", "PD-QA-0817-0822", "PD-QA-0554-0556", "PD-QA-0935-0940", "PD-QA-0614-0616", "PD-QA-0246-0247", "PD-QA-0246-0247", "PD-QA-0488-0490", "PD-QA-0110-0110", "PD-QA-0739-0743", "PD-QA-0192-0193", "PD-QA-0100-0100", "PD-QA-0100-0100", "PD-QA-0683-0686", "PD-QA-0596-0598", "PD-QA-0385-0386", "PD-QA-0628-0630", "PD-QA-0052-0052", "PD-QA-0052-0052", "PD-QA-0489-0491", "PD-QA-0489-0491", "PD-QA-0189-0190", "PD-QA-0092-0092", "PD-QA-0093-0093", "PD-QA-0094-0094", "PD-QA-0087-0087", "PD-QA-0095-0095", "PD-QA-0096-0096", "PD-QA-0088-0088", "PD-QA-0089-0089", "PD-QA-0090-0090", "PD-QA-0091-0091", "PD-QA-0271-0272", "PD-QA-0327-0328", "PD-QA-0736-0740", "PD-QA-0257-0258", "PD-QA-0418-0420", "PD-QA-0069-0069", "PD-QA-0069-0069", "PD-QA-0168-0168", "PD-QA-0169-0169", "PD-QA-0170-0170", "PD-QA-0170-0170", "PD-QA-0171-0171", "PD-QA-0171-0171", "PD-QA-0172-0172", "PD-QA-0172-0172", "PD-QA-0173-0173", "PD-QA-0173-0173", "PD-QA-0174-0174", "PD-QA-0174-0174", "PD-QA-0175-0175", "PD-QA-0175-0175", "PD-QA-0080-0080", "PD-QA-0255-0256", "PD-QA-0770-0774", "PD-QA-0905-0910", "PD-QA-0481-0483", "PD-QA-0481-0483", "PD-QA-0597-0599", "PD-QA-0541-0543", "PD-QA-0598-0600", "PD-QA-0330-0331", "PD-QA-0330-0331", "PD-QA-0724-0728", "PD-QA-0771-0775", "PD-QA-0333-0334", "PD-QA-0153-0153", "PD-QA-0639-0642", "PD-QA-0639-0642", "PD-QA-0745-0749", "PD-QA-0605-0607", "PD-QA-0605-0607", "PD-QA-0214-0215", "PD-QA-0214-0215", "PD-QA-0134-0134", "PD-QA-0134-0134", "PD-QA-0322-0323", "PD-QA-0750-0754", "PD-QA-0750-0754", "PD-QA-0053-0053", "PD-QA-0053-0053", "PD-QA-0749-0753", "PD-QA-0749-0753", "PD-QA-0686-0689", "PD-QA-0331-0332", "PD-QA-0331-0332", "PD-QA-0751-0755", "PD-QA-0751-0755", "PD-QA-0002-0002", "PD-QA-0502-0504", "PD-QA-0846-0851", "PD-QA-0079-0079", "PD-QA-0305-0306", "PD-QA-0335-0336", "PD-QA-0612-0614", "PD-QA-0867-0872", "PD-QA-0218-0219", "PD-QA-0256-0257", "PD-QA-0642-0645", "PD-QA-0646-0649", "PD-QA-0553-0555", "PD-QA-0131-0131", "PD-QA-0131-0131", "PD-QA-0927-0932", "PD-QA-0941-0946", "PD-QA-0589-0591", "PD-QA-0742-0746", "PD-QA-0699-0702", "PD-QA-0748-0752", "PD-QA-0748-0752", "PD-QA-0111-0111", "PD-QA-0694-0697", "PD-QA-0695-0698", "PD-QA-0696-0699", "PD-QA-0697-0700"]
Project.where(code: project_codes).update_all(district: "Lusail- Fox Hills")

project_codes = ["PD-QA-0643-0646", "PD-QA-0737-0741-QSAS", "PD-QA-0737-0741-QSAS", "PD-QA-0144-0144", "PD-QA-0144-0144", "PD-QA-0008-0008", "PD-QA-0008-0008", "PD-QA-0099-0099", "PD-QA-0099-0099", "PD-QA-0101-0101", "PD-QA-0446-0448", "PD-QA-0446-0448", "PD-QA-0743-0747", "PD-QA-0004-0004", "PD-QA-0004-0004", "PD-QA-0046-0046", "PD-QA-0215-0216", "PD-QA-0215-0216", "PD-QA-0332-0333", "PD-QA-0421-0423", "PD-QA-0302-0303", "PD-QA-0325-0326", "PD-QA-0061-0061", "PD-QA-0061-0061", "PD-QA-0068-0068", "PD-QA-0068-0068", "PD-QA-0182-0183", "PD-QA-0182-0183", "PD-QA-0500-0502", "PD-QA-0007-0007", "PD-QA-0007-0007", "PD-QA-0719-0723", "PD-QA-0210-0211", "PD-QA-0117-0117", "PD-QA-0012-0012", "PD-QA-0738-0742", "PD-QA-0066-0066", "PD-QA-0066-0066", "PD-QA-0252-0253", "PD-QA-0265-0266", "PD-QA-0265-0266", "PD-QA-0208-0209", "PD-QA-0501-0503", "PD-QA-0183-0184", "PD-QA-0183-0184", "PD-QA-0381-0382", "PD-QA-0122-0122", "PD-QA-0814-0819", "PD-QA-0769-0773", "PD-QA-0633-0635", "PC-QA-0024-0024", "PD-QA-0258-0259", "PC-QA-0024-0024", "PC-QA-0024-0024", "PD-QA-0104-0104", "PD-QA-0104-0104", "PD-QA-0014-0014", "PD-QA-0014-0014", "PD-QA-0762-0766", "PD-QA-0762-0766", "PD-QA-0056-0056", "PD-QA-0056-0056", "PD-QA-0358-0359", "PD-QA-0530-0532", "PD-QA-0310-0311", "PD-QA-0291-0292", "PD-QA-0123-0123", "PD-QA-0082-0082", "PD-QA-0015-0015", "PD-QA-0015-0015", "PD-QA-0067-0067", "PD-QA-0067-0067"]
Project.where(code: project_codes).update_all(district: "Lusail- Marina")

project_codes = ["PD-QA-0593-0595", "PD-QA-0593-0595", "PD-QA-0594-0596", "PD-QA-0594-0596"]
Project.where(code: project_codes).update_all(district: "Lusail- North-_RES")

project_codes = ["PD-QA-0804-0809", "PD-QA-0804-0809", "PD-QA-0895-0900", "PD-QA-0896-0901", "PD-QA-0897-0902", "PD-QA-0898-0903", "PD-QA-0899-0904", "PD-QA-0900-0905"]
Project.where(code: project_codes).update_all(district: "Lusail- Qetaifan")

project_codes = ["PC-QA-0030-0030", "PC-QA-0030-0030", "PC-QA-0030-0030"]
Project.where(code: project_codes).update_all(district: "Lusail- Qetaifan Islands")

project_codes =["PD-QA-0482-0484-SC", "PD-QA-0482-0484-SC", "PC-QA-0026-0026", "PC-QA-0026-0026", "PC-QA-0026-0026", "PD-QA-0818-0823"]
Project.where(code: project_codes).update_all(district: "Lusail- Stadium District")

project_codes = ["PD-QA-0711-0715 (obsolete)", "PD-QA-0711-0715", "PD-QA-0711-0715/CDA", "PD-QA-0357-0358", "PD-QA-0266-0267", "PD-QA-0260-0261", "PD-QA-0260-0261", "PD-QA-0408-0409/D3", "PD-QA-0408-0409/D3", "PD-QA-0408-0409/D4", "PD-QA-0408-0409/D4", "PD-QA-0312-0313", "PD-QA-0313-0314", "PD-QA-0624-0626", "PD-QA-0525-0527", "PD-QA-0081-0081", "PD-QA-0219-0220", "PD-QA-0470-0472", "PC-QA-0034-0034", "PC-QA-0034-0034", "PD-QA-0445-0447", "PD-QA-0773-0777"]
Project.where(code: project_codes).update_all(district: "Lusail- Waterfront_COM/SEEF")

project_codes = ["PD-QA-0856-0861__need to be deleted", "PD-QA-0856-0861", "PD-QA-0389-0390", "PD-QA-0355-0356", "PD-QA-0297-0298", "PD-QA-0544-0546", "PD-QA-0556-0558", "PD-QA-0328-0329", "PD-QA-0356-0357", "PD-QA-0577-0579", "PD-QA-0321-0322", "PD-QA-0576-0578", "PD-QA-0263-0264", "PD-QA-0263-0264", "PD-QA-0442-0444", "PD-QA-0772-0776", "PD-QA-0832-0837", "PD-QA-0692-0695", "PD-QA-0824-0829"]
Project.where(code: project_codes).update_all(district: "Lusail- Waterfront_RES")
