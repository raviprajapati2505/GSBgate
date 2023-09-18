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

  def certificate_intro_text(certificate_name, certificate_stage = '')
    case certificate_name
    when 'Letter of Conformance'
      text = "This is to notify that GSAS Trust has reviewed the project based on the submitted information. The project is found eligible to receive the Design Certificate as a provision for final GSAS Design & Build Certificate in the form of \"Letter of Conformance (LOC)\", The project is achieving: \n"
    when 'GSAS-CM', 'Construction Certificate'
      case certificate_stage
        when 'Stage 1: Foundation'
          text = "This is to notify that GSAS Trust has reviewed the construction submittals in accordance with the latest GSAS Construction Management assessments and has completed the Initial Site Audit requirements of Construction Stage 1 (Enabing Works). The project is found eligible to receive the First Interim Audit Advisory Notice (AAN) No.01 achieving the following: \n"
        when 'Stage 2: Substructure & Superstructure'
          text = "This is to notify that GSAS Trust has reviewed the construction submittals in accordance with the latest GSAS Construction Management assessments and has completed the Second Site Audit requirements of Construction Stage 2 (Substructure & Superstructure Works). The project is found eligible to receive the Second Interim Audit Advisory Notice (AAN) No.02 achieving the following: \n"
        when 'Stage 3: Finishing'
          text = "This is to notify that GSAS Trust has reviewed the construction submittals in accordance with the latest GSAS Construction Management assessments and has completed the Third Site Audit requirements of Construction Stage 3 (Finishing Works). The project is found eligible to receive the Third Interim Audit Advisory Notice (AAN) No.03 achieving the following: \n"
      end
    else
    end
  end

  def certificate_summary_text(certificate_name, certificate_stage = '')
    case certificate_name 
      when 'Letter of Conformance'
        text = { "1" => "The summary of the obtained rating is attached herewith.", 
          "2" => "This letter is only the predecessor towards achieving the final GSAS-D&B Certificate and should not be considered as the final certificate. The project should satisfy during the construction stage all the requirements of <b>Conformance to Design Audit (CDA)</b> which is a pre-requisite for the final GSAS-D&B Certificate as indicated in GSAS Technical Guide, <span style='color: #337ab7'>www.gsas.gord.qa</span> \n\n", 
          "3" => "In the event of any future changes applied to the criteria pertaining to this issued certificate, the changes are required to be re-assessed once again.", 
          "4" => "Finally, congratulations on partaking in this noble endeavor. We look forward to creating jointly a healthy and sustainable future." 
        }
      when 'GSAS-CM', 'Construction Certificate' 
        case certificate_stage
          when 'Stage 1: Foundation'
            interim_count = 'First'
          when 'Stage 2: Substructure & Superstructure'
            interim_count = 'Second'
          when 'Stage 3: Finishing'
            interim_count = 'Third'
          else
            interim_count = 'First'
        end
        text = { "1" => "Criteria summary of the #{interim_count} Interim Audit Advisory Notice is attached herewith.", 
          "2" => "This notice is only the predecessor towards achieving the final GSAS-CM Certificate and should not be considered as the final certificate. For further information please refer to GSAS Technical Guide, <span style='color: #337ab7'>www.gsas.gord.qa</span> \n", 
          "3" => "Finally, congratulations on partaking in this noble endeavor, and together let us build healthy and sustainable future."
        }
      else
      end
  end

  def get_certification_achieved_score(project, certification_path)
    if certification_path.construction?
      if certification_path.name == "Construction Certificate, 2019 - GSAS-CM Certificate"
        data_score = []
        certification_path_ids = project.certification_paths.pluck(:id) - [certification_path.id]
        certification_path_ids.each do |cp_id|
          scheme_mix = CertificationPath.find(cp_id)&.scheme_mixes&.first
          scheme_mix_scores = score_calculation(scheme_mix)
          data_score << scheme_mix_scores
        end
        scores = total_CM_score(data_score)
        scores = final_cm_revised_avg_scores(certification_path, scores)
      else
        scheme_mix = certification_path&.scheme_mixes&.first
        scores = score_calculation(scheme_mix)
      end

    else
      scores = certification_path.scores_in_certificate_points
    end
  end
end