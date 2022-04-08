module ReportsHelper
  def certificate_name(name)
    text = "#{@certification_path.name} Criteria Summary \n #{@certification_path.project.name}"
  end

  def certification_type_name(certification_path)
    project_type =  case certification_path&.project.certificate_type
                    when 1
                      'CONSTRUCTION MANAGEMENT'
                    when 2 
                      'OPERATION'
                    when 3
                      'DESIGN & BUILD'
                    end
    
    certificate_name =  case certification_path&.certificate.only_name
                        when "Letter of Conformance"
                          'DESIGN CERTIFICATE _ LETTER OF CONFORMANCE (LOC)'
                        when "Final Design Certificate" 
                          'DESIGN CERTIFICATE _ CONFORMANCE TO DESIGN AUDIT (CDA)'
                        when "GSAS-CM", "Construction Certificate"
                          stage_number =  case certification_path&.certificate&.stage_title
                                          when 'Stage 1: Foundation'
                                            '01'
                                          when 'Stage 2: Substructure & Superstructure'
                                            '02'
                                          when 'Stage 3: Finishing'
                                            '03'
                                          end
                          "AUDIT ADVISORY NOTICE (AAN) - No.#{stage_number}"
                        else
                          certification_path&.certificate.only_name
                        end

    return {project_type: project_type, certificate_name: certificate_name}
  end
end