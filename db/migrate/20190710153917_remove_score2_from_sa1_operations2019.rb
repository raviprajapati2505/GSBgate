class RemoveScore2FromSa1Operations2019 < ActiveRecord::Migration[5.2]
  def change
    scheme_criteria = [
      SchemeCriterion.find_by(name: "Sustainability Awareness", number: 1, scheme_category: SchemeCategory.find_by(code: "SA", scheme: Scheme.find_by(name: "Premium Scheme", gsas_document: "GSAS Operations_Assessment & Guidelines_2019_04.html", gsas_version: "2019", certificate_type: Certificate.certificate_types[:operations_type], renovation:false))),
      SchemeCriterion.find_by(name: "Sustainability Awareness", number: 1, scheme_category: SchemeCategory.find_by(code: "SA", scheme: Scheme.find_by(name: "Standard Scheme", gsas_document: "GSAS Operations_Assessment & Guidelines_2019_04.html", gsas_version: "2019", certificate_type: Certificate.certificate_types[:operations_type], renovation:false))),
    ]

    scheme_criteria.each do |sc|
      sc.update_column(:scores_a, YAML.load("[0, 1, 3]\n"))
    end
  end
end
