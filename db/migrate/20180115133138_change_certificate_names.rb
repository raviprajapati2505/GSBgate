class ChangeCertificateNames < ActiveRecord::Migration[4.2]
  def change
    certificates = Certificate.all
    certificates.each do |certificate|
      if certificate.construction_type?
        if certificate.gsas_version == '2.1 issue 1'
          case Certificate.certification_types[certificate.certification_type]
            when Certificate.certification_types[:construction_certificate]
              certificate.name = 'GSAS-CM, v2.1 Issue 1.0- GSAS-CM Certificate'
            when Certificate.certification_types[:construction_certificate_stage1]
              certificate.name = 'GSAS-CM, v2.1 Issue 1.0- Stage 1'
            when Certificate.certification_types[:construction_certificate_stage2]
              certificate.name = 'GSAS-CM, v2.1 Issue 1.0- Stage 2'
            when Certificate.certification_types[:construction_certificate_stage3]
              certificate.name = 'GSAS-CM, v2.1 Issue 1.0- Stage 3'
          end
          certificate.gsas_version = 'v2.1 Issue 1.0'
        else
          case Certificate.certification_types[certificate.certification_type]
            when Certificate.certification_types[:construction_certificate]
              certificate.name = 'GSAS-CM, v2.1 Issue 3.0- GSAS-CM Certificate'
            when Certificate.certification_types[:construction_certificate_stage1]
              certificate.name = 'GSAS-CM, v2.1 Issue 3.0- Stage 1'
            when Certificate.certification_types[:construction_certificate_stage2]
              certificate.name = 'GSAS-CM, v2.1 Issue 3.0- Stage 2'
            when Certificate.certification_types[:construction_certificate_stage3]
              certificate.name = 'GSAS-CM, v2.1 Issue 3.0- Stage 3'
          end
          certificate.gsas_version = 'v2.1 Issue 3.0'
        end
      else
        certificate.name = certificate.name + ', v' + certificate.gsas_version
        certificate.gsas_version = 'v' + certificate.gsas_version
      end
      certificate.save!
    end

  end
end
