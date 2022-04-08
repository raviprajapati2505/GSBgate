class AddCertificationStatusToCgpCertificationPathDocument < ActiveRecord::Migration[5.2]
  def up
    add_reference :documents, :certification_path_status, index: true, foreign_key: true

    CertificationPath.all.each do |certification_path|
      certification_path.cgp_certification_path_documents.update_all(certification_path_status_id: certification_path.certification_path_status_id)

      scheme_mix_criteria_documents = Document.joins(scheme_mix_criteria_documents: [scheme_mix_criterion: [scheme_mix: :certification_path]]).where("certification_paths.id = :certification_path_id", certification_path_id: certification_path.id)
      scheme_mix_criteria_documents.update_all(certification_path_status_id: certification_path.certification_path_status_id)
    end
  end

  def down
    remove_reference :documents, :certification_path_status
  end
end
