class InitScoreAcm21Issue1 < ActiveRecord::Migration
  def change
    SchemeCriterion.joins(scheme_category: {scheme: {development_types: :certificate}}).where("certificates.certificate_type = 1 AND certificates.gsas_version = 'v2.1 Issue 1.0'").update_all(scores_a: [[0, 0.0]])
  end
end
