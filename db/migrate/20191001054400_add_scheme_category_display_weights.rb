class AddSchemeCategoryDisplayWeights < ActiveRecord::Migration[5.2]
  def change
    # Design&Build 2019
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:design_type]}, code: "CE").update_all(display_weight: 7)
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:design_type]}, code: "E").update_all(display_weight: 3)
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:design_type]}, code: "IE").update_all(display_weight: 6)
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:design_type]}, code: "M").update_all(display_weight: 5)
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:design_type]}, code: "MO").update_all(display_weight: 8)
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:design_type]}, code: "S").update_all(display_weight: 2)
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:design_type]}, code: "UC").update_all(display_weight: 1)
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:design_type]}, code: "W").update_all(display_weight: 4)

    # Operations 2019
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:operations_type]}, code: "FM").update_all(display_weight: 5)
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:operations_type]}, code: "IE").update_all(display_weight: 3)
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:operations_type]}, code: "WM").update_all(display_weight: 4)
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:operations_type]}, code: "E").update_all(display_weight: 1)
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:operations_type]}, code: "SA").update_all(display_weight: 6)
    SchemeCategory.joins(:scheme).where(schemes: {gsas_version: "2019", certificate_type: Certificate.certificate_types[:operations_type]}, code: "W").update_all(display_weight: 2)
  end
end
