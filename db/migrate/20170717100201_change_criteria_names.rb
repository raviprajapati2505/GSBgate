class ChangeCriteriaNames < ActiveRecord::Migration
  def change
    # Change MO.2 & MO.3 criteria names
    schemes = Scheme.where(id: [2, 14, 15, 21, 22, 26, 32, 34, 41, 47, 53, 60, 67, 68, 74,  76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86])
    schemes.each do |scheme|
      categories = SchemeCategory.where(scheme: scheme)
      categories.each do |category|
        criteria = SchemeCriterion.where(scheme_category: category)
        criteria.each do |criterion|
          if category.code == 'MO'
            if scheme.name == 'Commercial'
              if criterion.number == 2
                criterion.name = 'Waste (Recycling) Management'
              end
            elsif scheme.name == 'Education'
              if criterion.number == 2
                criterion.name = 'Waste (Recycling) Management'
              end
            elsif scheme.name == 'Residential - Group'
              if criterion.number == 2
                criterion.name = 'Waste (Recycling) Management'
              end
            elsif scheme.name == 'Mosques'
              if criterion.number == 2
                criterion.name = 'Waste (Recycling) Management'
              end
            elsif scheme.name == 'Hotels'
              if criterion.number == 2
                criterion.name = 'Waste (Recycling) Management'
              end
            elsif scheme.name == 'Light Industry'
              if criterion.number == 2
                criterion.name = 'Waste (Recycling) Management'
              end
            elsif scheme.name == 'Workers Accomodation'
              if criterion.number == 2
                criterion.name = 'Waste (Recycling) Management'
              end
            elsif scheme.name == 'Sports'
              if criterion.number == 2
                criterion.name = 'Waste (Recycling) Management'
              end
            elsif scheme.name == 'Healthcare'
              if criterion.number == 2
                criterion.name = 'Waste (Recycling) Management'
              end
            elsif scheme.name == 'Railways'
              if criterion.number == 2
                criterion.name = 'Waste (Recycling) Management'
              end
            elsif scheme.name == 'Parks'
              if criterion.number == 2
                criterion.name = 'Waste (Recycling) Management'
              end
            end
          end
          criterion.save!
        end
      end
    end

    criteria = SchemeCriterion.joins(scheme_category: [:scheme]).where(number: 3, name: 'Recycling Management', scheme_categories: {code: 'MO'}, schemes: {gsas_version: '2.1'})
    criteria.each do |criterion|
      criterion.name = 'Facility Management'
      criterion.save!
    end

    # Link scheme 'Mosques' to criterion 'Waste (Recycling) Management' with weight 1.05% and scores '[0, 1, 2, 3]'
    SchemeCriterion.create!(weight: 1.05, name: 'Waste (Recycling) Management', number: 2, scores: YAML.load("[0, 1, 2, 3]\n"), scheme_category_id: 300, minimum_score: 0, maximum_score: 3, minimum_valid_score: 0, incentive_weight_minus_1: 0.0, incentive_weight_0: 0.0, incentive_weight_1: 0.0, incentive_weight_2: 0.0, incentive_weight_3: 0.0)
  end
end
