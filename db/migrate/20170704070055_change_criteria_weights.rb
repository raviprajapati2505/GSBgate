class ChangeCriteriaWeights < ActiveRecord::Migration[4.2]
  def change
      # MO.2 scores and MO.2&MO.3 weights

      # Copy Schemes, Categories, Criteria, scheme_criterion_texts, scheme_criteria_requirements, for Design&Build Certificates version 2.1
      # only for schemes linked to development types Neighborhoods, Districts and Infrastructures
      orig_schemes = Scheme.where(id: [5, 18, 23, 29, 37, 44, 48, 50, 56, 70, 75])
      orig_schemes.each do |orig_scheme|
        scheme_copy = orig_scheme.dup
        scheme_copy.save!
        criteria_copies = Hash.new
        orig_categories = SchemeCategory.where(scheme: orig_scheme)
        orig_categories.each do |orig_category|
          category_copy = orig_category.dup
          category_copy.scheme = scheme_copy
          category_copy.save!
          orig_criteria = SchemeCriterion.where(scheme_category: orig_category)
          orig_criteria.each do |orig_criterion|
            criterion_copy = orig_criterion.dup
            criterion_copy.scheme_category = category_copy
            if orig_category.code == 'MO'
              if orig_scheme.name == 'Commercial'
                if orig_criterion.number == 2
                  criterion_copy.weight = 1.58
                  criterion_copy.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  criterion_copy.weight = 0.68
                end
              elsif orig_scheme.name == 'Education'
                if orig_criterion.number == 2
                  criterion_copy.weight = 1.22
                  criterion_copy.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  criterion_copy.weight = 0.53
                end
              elsif orig_scheme.name == 'Residential - Group'
                if orig_criterion.number == 2
                  criterion_copy.weight = 4.50
                  criterion_copy.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  criterion_copy.weight = 0.79
                end
              elsif orig_scheme.name == 'Mosques'
                if orig_criterion.number == 2
                  criterion_copy.weight = 1.05
                  criterion_copy.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  criterion_copy.weight = 1.05
                end
              elsif orig_scheme.name == 'Hotels'
                if orig_criterion.number == 2
                  criterion_copy.weight = 1.61
                  criterion_copy.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  criterion_copy.weight = 0.69
                end
              elsif orig_scheme.name == 'Light Industry'
                if orig_criterion.number == 2
                  criterion_copy.weight = 1.58
                  criterion_copy.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  criterion_copy.weight = 0.68
                end
              elsif orig_scheme.name == 'Workers Accomodation'
                if orig_criterion.number == 2
                  criterion_copy.weight = 1.57
                  criterion_copy.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  criterion_copy.weight = 0.68
                end
              elsif orig_scheme.name == 'Sports'
                if orig_criterion.number == 2
                  criterion_copy.weight = 1.56
                  criterion_copy.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  criterion_copy.weight = 0.67
                end
              elsif orig_scheme.name == 'Healthcare'
                if orig_criterion.number == 2
                  criterion_copy.weight = 1.40
                  criterion_copy.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  criterion_copy.weight = 0.60
                end
              elsif orig_scheme.name == 'Railways'
                if orig_criterion.number == 2
                  criterion_copy.weight = 1.56
                  criterion_copy.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  criterion_copy.weight = 0.67
                end
              elsif orig_scheme.name == 'Parks'
                if orig_criterion.number == 2
                  criterion_copy.weight = 4.33
                  criterion_copy.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  criterion_copy.weight = 1.23
                end
              end
            end
            criterion_copy.save!
            criteria_copies[orig_criterion.id] = criterion_copy.id
            orig_criterion_texts = SchemeCriterionText.where(scheme_criterion: orig_criterion)
            orig_criterion_texts.each do |orig_criterion_text|
              criterion_text_copy = orig_criterion_text.dup
              criterion_text_copy.scheme_criterion = criterion_copy
              if orig_category.code == 'MO' && orig_criterion.number == 2
                if orig_criterion_text.name == 'DESCRIPTION'
                  criterion_text_copy.html_text = "<p>Encourage planning for the collection and composting of organic waste, as well as the planning to designate containment facilities for the building's recyclable materials in order to minimize waste taken to landfills or incineration facilities.</p>"
                elsif orig_criterion_text.name == 'MEASUREMENT PRINCIPLE'
                  criterion_text_copy.html_text = "<p>Project will develop and implement a Waste (Recycling) Management Plan for the collection, storage, and composting of organic waste materials, and for the collection, storage, and removal of recyclable materials.</p>"
                elsif orig_criterion_text.name == 'MEASUREMENT'
                  criterion_text_copy.html_text = "<p>Projects composting organic waste and recycling materials off-site, will demonstrate that a central storage area for compostable materials is located close to a truck loading area and that sufficient storage has been provided for the recyclable materials produced. The Waste (Recycling) Management Plan will outline the collection procedures on how the organic waste and recyclable materials will be handled at the off-site facility.</p>" \
                                                "<p>If composting is done on-site, the Waste (Recycling) Management Plan will outline the collection procedures for organic waste and recyclable materials in the project to demonstrate that organic materials will be easily collected and removed for composting, and that recyclable materials will be easily collected and sorted at a facility or off-site.</p>" \
                                                "<p>All projects composting organic waste and recycling materials on- or off-site will ensure that the storage area or composting facility must be properly isolated and ventilated to reduce negative health impacts for building users and visitors.</p>"
                elsif orig_criterion_text.name == 'SUBMITTAL'
                  criterion_text_copy.html_text = "<p>Submit a Waste (Recycling) Management as well as drawings demonstrating the collection, storage, and composting of organic waste, and recycling of materials on- or off-site.</p>"
                elsif orig_criterion_text.name == 'SCORE'
                  criterion_text_copy.html_text = '<table class="table table-bordered">' \
                                                '<colgroup><col></col><col></col></colgroup>' \
                                                '<tbody><tr><td><p>Score</p></td><td><p>Requirement</p></td></tr>' \
                                                '<tr><td><p>0</p></td><td><p>Waste (Recycling) Management Plan does not demonstrates compliance.</p></td></tr>' \
                  '<tr><td><p>1</p></td><td><p>Waste (Recycling) Management Plan demonstrates compliance with the requirements for the collection, storage, and final disposal of organic wastes and recyclable materials.</p></td></tr>' \
                  '<tr><td><p>2</p></td><td><p>Waste (Recycling) Management Plan demonstrates compliance with the requirements of score of 1 plus either the composting requirements of organic wastes or the recycling requirements of recyclable materials on- or off-site.</p></td></tr>' \
                  '<tr><td><p>3</p></td><td><p>Waste (Recycling) Management Plan demonstrates full compliance with the requirements for the collection, storage, and composting of organic wastes and recycling of recyclable materials on- or off-site.</p></td></tr></tbody></table>'
                end
              end
              criterion_text_copy.save!
            end
            # link with existing requirements
            orig_criteria_requirements = SchemeCriteriaRequirement.where(scheme_criterion: orig_criterion)
            orig_criteria_requirements.each do |orig_criteria_requirement|
              criterion_requirement_copy = orig_criteria_requirement.dup
              criterion_requirement_copy.scheme_criterion = criterion_copy
              criterion_requirement_copy.save!
            end
          end
        end
        # link with existing development types
        development_type_schemes = DevelopmentTypeScheme.where(scheme: orig_scheme)
        development_type_schemes.each do |development_type_scheme|
          if (development_type_scheme.development_type.name =~ %r"(District|Neighbourhood)") != 0
            development_type_scheme.scheme = scheme_copy
            development_type_scheme.save!

            # link with existing scheme_mixes
            scheme_mixes = SchemeMix.joins(certification_path: [:development_type]).where(scheme: orig_scheme, certification_paths: {development_type: development_type_scheme.development_type})
            scheme_mixes.each do |scheme_mix|
              scheme_mix.scheme = scheme_copy
              scheme_mix.save!
              scheme_mix_criteria = SchemeMixCriterion.where(scheme_mix: scheme_mix)
              scheme_mix_criteria.each do |scheme_mix_criterion|
                scheme_mix_criterion.scheme_criterion_id = criteria_copies[scheme_mix_criterion.scheme_criterion_id]
                scheme_mix_criterion.save!
              end
            end
          end
        end
      end

      # Update other
      orig_schemes = Scheme.where(id: [2, 14, 15, 21, 22, 26, 32, 34, 41, 47, 53, 60, 67, 68, 74])
      orig_schemes.each do |orig_scheme|
        orig_categories = SchemeCategory.where(scheme: orig_scheme)
        orig_categories.each do |orig_category|
          orig_criteria = SchemeCriterion.where(scheme_category: orig_category)
          orig_criteria.each do |orig_criterion|
            if orig_category.code == 'MO'
              if orig_scheme.name == 'Commercial'
                if orig_criterion.number == 2
                  orig_criterion.weight = 1.58
                  orig_criterion.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  orig_criterion.weight = 0.68
                end
              elsif orig_scheme.name == 'Education'
                if orig_criterion.number == 2
                  orig_criterion.weight = 1.22
                  orig_criterion.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  orig_criterion.weight = 0.53
                end
              elsif orig_scheme.name == 'Residential - Group'
                if orig_criterion.number == 2
                  orig_criterion.weight = 4.50
                  orig_criterion.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  orig_criterion.weight = 0.79
                end
              elsif orig_scheme.name == 'Mosques'
                if orig_criterion.number == 2
                  orig_criterion.weight = 1.05
                  orig_criterion.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  orig_criterion.weight = 1.05
                end
              elsif orig_scheme.name == 'Hotels'
                if orig_criterion.number == 2
                  orig_criterion.weight = 1.61
                  orig_criterion.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  orig_criterion.weight = 0.69
                end
              elsif orig_scheme.name == 'Light Industry'
                if orig_criterion.number == 2
                  orig_criterion.weight = 1.58
                  orig_criterion.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  orig_criterion.weight = 0.68
                end
              elsif orig_scheme.name == 'Workers Accomodation'
                if orig_criterion.number == 2
                  orig_criterion.weight = 1.57
                  orig_criterion.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  orig_criterion.weight = 0.68
                end
              elsif orig_scheme.name == 'Sports'
                if orig_criterion.number == 2
                  orig_criterion.weight = 1.56
                  orig_criterion.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  orig_criterion.weight = 0.67
                end
              elsif orig_scheme.name == 'Healthcare'
                if orig_criterion.number == 2
                  orig_criterion.weight = 1.40
                  orig_criterion.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  orig_criterion.weight = 0.60
                end
              elsif orig_scheme.name == 'Railways'
                if orig_criterion.number == 2
                  orig_criterion.weight = 1.56
                  orig_criterion.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  orig_criterion.weight = 0.67
                end
              elsif orig_scheme.name == 'Parks'
                if orig_criterion.number == 2
                  orig_criterion.weight = 4.33
                  orig_criterion.scores = YAML.load("[0, 1, 2, 3]\n")
                elsif orig_criterion.number == 3
                  orig_criterion.weight = 1.23
                end
              end
            end
            orig_criterion.save!
            orig_criterion_texts = SchemeCriterionText.where(scheme_criterion: orig_criterion)
            orig_criterion_texts.each do |orig_criterion_text|
              if orig_category.code == 'MO' && orig_criterion.number == 2
                if orig_criterion_text.name == 'DESCRIPTION'
                  orig_criterion_text.html_text = "<p>Encourage planning for the collection and composting of organic waste, as well as the planning to designate containment facilities for the building&rsquo;s recyclable materials in order to minimize waste taken to landfills or incineration facilities.</p>"
                elsif orig_criterion_text.name == 'MEASUREMENT PRINCIPLE'
                  orig_criterion_text.html_text = "<p>Project will develop and implement a Waste (Recycling) Management Plan for the collection, storage, and composting of organic waste materials, and for the collection, storage, and removal of recyclable materials.</p>"
                elsif orig_criterion_text.name == 'MEASUREMENT'
                  orig_criterion_text.html_text = "<p>Projects composting organic waste and recycling materials off-site, will demonstrate that a central storage area for compostable materials is located close to a truck loading area and that sufficient storage has been provided for the recyclable materials produced. The Waste (Recycling) Management Plan will outline the collection procedures on how the organic waste and recyclable materials will be handled at the off-site facility.</p>" \
                                                "<p>If composting is done on-site, the Waste (Recycling) Management Plan will outline the collection procedures for organic waste and recyclable materials in the project to demonstrate that organic materials will be easily collected and removed for composting, and that recyclable materials will be easily collected and sorted at a facility or off-site.</p>" \
                                                "<p>All projects composting organic waste and recycling materials on- or off-site will ensure that the storage area or composting facility must be properly isolated and ventilated to reduce negative health impacts for building users and visitors.</p>"
                elsif orig_criterion_text.name == 'SUBMITTAL'
                  orig_criterion_text.html_text = "<p>Submit a Waste (Recycling) Management as well as drawings demonstrating the collection, storage, and composting of organic waste, and recycling of materials on- or off-site.</p>"
                elsif orig_criterion_text.name == 'SCORE'
                  orig_criterion_text.html_text = '<table class="table table-bordered">' \
                                                '<colgroup><col></col><col></col></colgroup>' \
                                                '<tbody><tr><td><p>Score</p></td><td><p>Requirement</p></td></tr>' \
                                                '<tr><td><p>0</p></td><td><p>Waste (Recycling) Management Plan does not demonstrates compliance.</p></td></tr>' \
                  '<tr><td><p>1</p></td><td><p>Waste (Recycling) Management Plan demonstrates compliance with the requirements for the collection, storage, and final disposal of organic wastes and recyclable materials.</p></td></tr>' \
                  '<tr><td><p>2</p></td><td><p>Waste (Recycling) Management Plan demonstrates compliance with the requirements of score of 1 plus either the composting requirements of organic wastes or the recycling requirements of recyclable materials on- or off-site.</p></td></tr>' \
                  '<tr><td><p>3</p></td><td><p>Waste (Recycling) Management Plan demonstrates full compliance with the requirements for the collection, storage, and composting of organic wastes and recycling of recyclable materials on- or off-site.</p></td></tr></tbody></table>'
                end
              end
              orig_criterion_text.save!
            end
          end
        end
      end

      # MO.3 scores
      criteria = SchemeCriterion.joins(scheme_category: [:scheme]).where(number: 3, name: 'Recycling Management', scheme_categories: {code: 'MO'}, schemes: {gsas_version: '2.1'})
      criteria.each do |criterion|
        criterion.scores = YAML.load("[0, 1, 3]\n")
        criterion.save!
        texts = SchemeCriterionText.where(scheme_criterion: criterion)
        texts.each do |text|
          if text.name == 'DESCRIPTION'
            text.html_text = '<p>Encourage strategic planning for a proactive delivery of services which includes understanding, analyzing, planning and development, operating and maintenance on the support for achievement of the organization&rsquo;s mission and vision.</p>'
          elsif text.name == 'MEASUREMENT PRINCIPLE'
            text.html_text = '<p>Project will develop and implement a Facility Management Plan setting benchmarks for excellence and continual improvement of the facilities towards achieving its sustainable operations.</p>'
          elsif text.name == 'MEASUREMENT'
            text.html_text = '<p>Project will develop and implement a Facility Management Plan encompassing the accountability, innovation, reliability, competency, excellence and sustainability of vision, mission, strategies, goals and services based on the organization&rsquo;s objectives. Facility Management Plan may include energy &amp; water management systems, asset management, parking management, traffic management &amp; controls, maintenance works, housekeeping services, safety &amp; security, video &amp; audio services, visitor management services and venue ICT services.</p>'
          elsif text.name == 'SUBMITTAL'
            text.html_text = '<p>Submit a Facility Management Plan outlining vision, mission and realistic goals tailored to meet the users need and the stakeholders&rsquo; requirements.</p>'
          elsif text.name == 'SCORE'
            text.html_text = '<table class="table table-bordered">' \
                           '<colgroup><col></col><col></col></colgroup>' \
                           '<tbody><tr><td><p>Score</p></td><td><p>Requirement</p></td></tr>' \
                           '<tr><td><p>0</p></td><td><p>Facility Management Plan does not demonstrate compliance.</p></td></tr>' \
                           '<tr><td><p>1</p></td><td><p>Facility Management Plan demonstrates partial compliance.</p></td></tr>' \
                           '<tr><td><p>3</p></td><td><p>Facility Management Plan demonstrates full compliance.*</p></td></tr></tbody></table>' \
                           '<p></p><p>&nbsp;</p><p>* Facility Management includes strategic planning for 2-5 years plan.</p>'
          end
          text.save!
        end
      end
  end
end
