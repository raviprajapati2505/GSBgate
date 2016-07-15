class UpdateIncentiveWeightsPerScore < ActiveRecord::Migration
  def up
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Commercial', 'Core + Shell', 'Education', 'Hotels', 'Light Industry', 'Mosques', 'Parks', 'Residential - Group'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_minus_1: 0)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Commercial', 'Core + Shell', 'Education', 'Hotels', 'Light Industry', 'Mosques', 'Parks', 'Residential - Group'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_0: 0)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Commercial', 'Core + Shell', 'Education', 'Hotels', 'Light Industry', 'Mosques', 'Parks', 'Residential - Group'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_1: 0.5)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Commercial', 'Core + Shell', 'Education', 'Hotels', 'Light Industry', 'Mosques', 'Parks', 'Residential - Group'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_2: 1)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Commercial', 'Core + Shell', 'Education', 'Hotels', 'Light Industry', 'Mosques', 'Parks', 'Residential - Group'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_3: 2)

    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Healthcare', 'Railways', 'Sports'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_minus_1: 0)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Healthcare', 'Railways', 'Sports'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_0: 0)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Healthcare', 'Railways', 'Sports'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_1: 0.25)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Healthcare', 'Railways', 'Sports'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_2: 0.5)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {name: ['Healthcare', 'Railways', 'Sports'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all(incentive_weight_3: 1)

    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'MO'}, number: 5, name: 'Energy & Water Use Sub-metering').update_all(incentive_weight_minus_1: 0)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'MO'}, number: 5, name: 'Energy & Water Use Sub-metering').update_all(incentive_weight_0: 0)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'MO'}, number: 5, name: 'Energy & Water Use Sub-metering').update_all(incentive_weight_1: 0.5)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'MO'}, number: 5, name: 'Energy & Water Use Sub-metering').update_all(incentive_weight_2: 0.5)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'MO'}, number: 5, name: 'Energy & Water Use Sub-metering').update_all(incentive_weight_3: 1)

    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'M'}, name: 'Life Cycle Assessment (LCA)').update_all(incentive_weight_minus_1: 0)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'M'}, name: 'Life Cycle Assessment (LCA)').update_all(incentive_weight_0: 0)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'M'}, name: 'Life Cycle Assessment (LCA)').update_all(incentive_weight_1: 2)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'M'}, name: 'Life Cycle Assessment (LCA)').update_all(incentive_weight_2: 2)
    SchemeCriterion.joins(scheme_category: [:scheme]).where.not(schemes: {gsas_document: ['Districts & Infrastructure GSAS Assessment v2-1_10.html', 'workers Accomodation GSAS Design Assessment v2.1.html']}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'M'}, name: 'Life Cycle Assessment (LCA)').update_all(incentive_weight_3: 2)

    # Fixing weight changes from old migration
    # - Typologies (remove weight)
    SchemeCriterion.joins(scheme_category: [:scheme]).where(schemes: {gsas_document: 'Typologies GSAS Design Assessment v2.1_Medium.html'}).where(schemes: {name: ['Commercial', 'Core + Shell', 'Education', 'Hotels', 'Light Industry', 'Mosques', 'Parks', 'Residential - Group'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all('weight = weight - 2.0')
    SchemeCriterion.joins(scheme_category: [:scheme]).where(schemes: {gsas_document: 'Typologies GSAS Design Assessment v2.1_Medium.html'}).where(schemes: {name: ['Healthcare', 'Railways', 'Sports'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, number: 11, name: 'GSAS Construction Management - Full').update_all('weight = weight - 1.0')
    SchemeCriterion.joins(scheme_category: [:scheme]).where(schemes: {gsas_document: 'Typologies GSAS Design Assessment v2.1_Medium.html'}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'MO'}, number: 5, name: 'Energy & Water Use Sub-metering').update_all('weight = weight - 1.0')
    SchemeCriterion.joins(scheme_category: [:scheme]).where(schemes: {gsas_document: 'Typologies GSAS Design Assessment v2.1_Medium.html'}).where(schemes: {gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'M'}, name: 'Life Cycle Assessment (LCA)').update_all('weight = weight - 2.0')

    # - Renovations
    SchemeCriterion.joins(scheme_category: [:scheme])
        .where(schemes: {gsas_document: 'Operations GSAS Assessment v2.1.html'})
        .where(schemes: {name: ['Sports'], gsas_version: "2.1", renovation: true, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'MO'}, name: 'Energy & Water Use Sub-metering')
        .update_all('weight = weight + 1.0, incentive_weight_1 = 0, incentive_weight_2 = 0, incentive_weight_3 = 0')

    SchemeCriterion.joins(scheme_category: [:scheme])
        .where(schemes: {gsas_document: 'Districts & Infrastructure GSAS Assessment v2-1_10.html'})
        .where(schemes: {name: ['Healthcare', 'Railways', 'Sports'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'M'}, name: 'Life Cycle Assessment (LCA)')
        .update_all('weight = weight + 2.0, incentive_weight_1 = 0, incentive_weight_2 = 0, incentive_weight_3 = 0')

    SchemeCriterion.joins(scheme_category: [:scheme])
        .where(schemes: {gsas_document: 'Parks GSAS Assessment v2-1_04.html'})
        .where(schemes: {name: ['Parks'], gsas_version: "2.1", renovation: false, certificate_type: Certificate.certificate_types[:design_type]}, scheme_categories: {code: 'S'}, name: 'GSAS Construction Management - Full')
        .update_all('weight = weight - 1.0')
  end

  def down
  end
end