module ScoreCalculator
  extend ActiveSupport::Concern

  POINT_TYPES = [:criteria_points, :scheme_points, :certificate_points]
  SCORE_FIELDS = [:achieved_score, :submitted_score, :targeted_score, :maximum_score, :minimum_score, :minimum_valid_score]
  GROUP_TYPES = [:scheme_mix_criteria_id, :certification_path_id, :scheme_mix_id, :scheme_criteria_id, :scheme_category_id]

  included do

    def scores_in_certificate_points
      fetch_scores([:certificate_points], SCORE_FIELDS)[0]
    end

    def scores_in_scheme_points
      fetch_scores([:scheme_points], SCORE_FIELDS)[0]
    end

    def scores_in_criteria_points
      fetch_scores([:criteria_points], SCORE_FIELDS)[0]
    end

    def scores(point_types=POINT_TYPES, score_fields=SCORE_FIELDS, group_types=[])
      fetch_scores(point_types, score_fields, group_types)[0]
    end

    def scheme_mix_criteria_scores(point_types=POINT_TYPES, score_fields=SCORE_FIELDS)
      fetch_scores(point_types, score_fields, GROUP_TYPES)
    end

    def has_achieved_score?
      !scores_in_certificate_points[:achieved_score_in_certificate_points].nil?
    end

    private

    def fetch_scores(point_types=POINT_TYPES, score_fields=SCORE_FIELDS, group_types=[])
      # build score selects
      score_selects = []
      point_types.each { |point_type|
        score_fields.each { |score_field|
          score_selects.push(self.class.query_score_template(point_type, score_field, ('%s_in_%s' % [score_field, point_type])))
        }
      }
      # build group selects
      group_fields = []
      group_selects = []
      group_types.each { |group_type|
        group_field = self.class.group_template(group_type)
        group_fields.push(group_field)
        group_selects.push('%s as %s' % [group_field, group_type])
      }
      # Do the query
      results = pluck_scores(score_selects, group_selects, group_fields)
      # Convert results into a hash
      records = results.map do |rec|
        h = Hash.new
        idx = 0
        point_types.each { |point_type|
          score_fields.each { |score_field|
            h[('%s_in_%s' % [score_field, point_type]).to_sym] = rec[idx]
            idx += 1
          }
        }
        group_types.each { |group_type|
          h[group_type] = rec[idx]
          idx += 1
        }
        h
      end
      return records
    end

    def pluck_scores(score_selects, group_selects=[], group_fields = [])
      relation = base_score_query
      group_fields.each do |group_field|
        relation = relation.group(group_field)
      end
      results = relation.pluck((score_selects + group_selects).join(', '))
      return results
    end

    def base_score_query
      relation = self.class.base_score_query
      case self.class.name
        when CertificationPath.name
          relation.where(scheme_mixes_score: {certification_path_id: self.id})
        when SchemeMix.name
          relation.where(scheme_mixes_score: {id: self.id})
        when SchemeMixCriterion.name
          relation.where(id: self.id)
        else
          raise('Unsupported class: ', self.name)
      end
    end
  end

  module ClassMethods

    def query_score_in_certificate_points(field_name)
      self.base_score_query.select(query_score_template(:certificate_points, field_name)).to_sql
    end

    def group_template(group_type)
      if group_type == :scheme_mix_criteria_id
        field_name = 'scheme_mix_criteria_score.id'
      elsif group_type == :certification_path_id
        field_name = 'scheme_mixes_score.certification_path_id'
      elsif group_type == :scheme_mix_id
        field_name = 'scheme_mix_criteria_score.scheme_mix_id'
      elsif group_type == :scheme_criteria_id
        field_name = 'scheme_mix_criteria_score.scheme_criterion_id'
      elsif group_type == :scheme_category_id
        field_name = 'scheme_criteria_score.scheme_category_id'
      else
        raise('Unexpected group type: ' + group_type.to_s)
      end
      field_name
    end

    def query_score_template(point_type, field_name, field_alias = '')
      # determine corresponding table for a given score field name
      field_table = field_table_for_field_name(field_name)

      # query that calculates the score for a specific score field
      score_calculation_query = build_score_calculation_query(field_name, field_table, point_type)

      # validations
      if field_name == :achieved_score or field_name == :submitted_score or field_name == :targeted_score
        # - validate certification path status
        check_certification_path_state = build_check_certification_path_state_query(field_name)

        # - validate minimum valid score (if the score is not below the minimum required valid score)
        check_minimum_valid_score = build_check_minimum_valid_score_query(field_name, field_table)

        # - validate scheme mix criterion status
        check_scheme_mix_criterion_state = build_check_scheme_mix_criterion_state_query(field_name)

        # NOTE: to use validations in a query, we do some magic tricks
        # - convert the boolean check value to a number, so we can use an aggregate function on it
        # - returning NULL if not all validations are ok
        # - OR returning the actual score calculation query
        validation_query_template = 'CASE MIN(CASE(%{check_certification_path_state} AND %{check_minimum_valid_score} AND %{check_scheme_mix_criterion_state}) WHEN true then 1 else 0 end) WHEN 1 THEN %{score_calculation_query} ELSE null end'
        validation_query = validation_query_template % {check_certification_path_state: check_certification_path_state, check_minimum_valid_score: check_minimum_valid_score, check_scheme_mix_criterion_state: check_scheme_mix_criterion_state, score_calculation_query: score_calculation_query}
      else
        validation_query = score_calculation_query
      end

      # alias part
      field_alias = ' as ' + field_alias unless field_alias.empty?
      return '%{validation_query}%{field_alias}' % {validation_query: validation_query, field_alias: field_alias}
    end

    def build_check_scheme_mix_criterion_state_query(field_name)
      # Note: this check ensures that assessors can not see the achieved scores, while the certification path is still under review
      # with one notable exception, they can see the scores for non appealed criteria during verification after appeal
      if field_name == :achieved_score
        # This check is only needed for 'verifying' an 'verifying after appeal', so if the state is different from those we can return 'true'
        certification_path_statuses_ok = 'certification_paths_score.certification_path_status_id NOT IN (%{certification_path_statuses})' % {certification_path_statuses: [CertificationPathStatus::VERIFYING, CertificationPathStatus::VERIFYING_AFTER_APPEAL].join(', ')}
        # if 'verifying' or 'verifying after appeal', return true for gsas trust admins and managers, or project certifiers, as they are allowed to see the achieved scores
        certification_path_status_verifying_or_verifying_after_appeal = 'certification_paths_score.certification_path_status_id IN (%{certification_path_statuses})' % {certification_path_statuses: [CertificationPathStatus::VERIFYING, CertificationPathStatus::VERIFYING_AFTER_APPEAL].join(', ')}
        user_is_manager = 'EXISTS(SELECT id FROM users WHERE id = %{user_id} AND role IN (%{user_roles}))' % {user_id: User.current.id, user_roles: [User.roles[:system_admin], User.roles[:gsas_trust_top_manager], User.roles[:gsas_trust_manager], User.roles[:gsas_trust_admin]].join(', ')}
        user_is_project_certifier = 'EXISTS(SELECT user_id FROM projects_users WHERE projects_users.project_id = projects.id AND projects_users.user_id = %{user_id} AND projects_users.role IN (%{project_roles}))' % {user_id: User.current.id, project_roles: [ProjectsUser.roles[:certifier], ProjectsUser.roles[:certification_manager]].join(', ')}
        # if 'verifying after appeal', assessor are only allowed to see the criteria without appeals (so those where accepted scores are: score_awarded, score_downgraded, score_upgraded or score_minimal)
        certification_path_status_verifying_after_appeal = 'certification_paths_score.certification_path_status_id = %{certification_path_status}' % {certification_path_status: CertificationPathStatus::VERIFYING_AFTER_APPEAL}
        scores_are_accepted = 'scheme_mix_criteria_score.status IN (%{scheme_mix_criterion_statuses})' % {scheme_mix_criterion_statuses: [SchemeMixCriterion::statuses[:score_awarded], SchemeMixCriterion::statuses[:score_downgraded], SchemeMixCriterion::statuses[:score_upgraded], SchemeMixCriterion::statuses[:score_minimal]].join(', ')}
        # combine all conditions above
        check_scheme_mix_criterion_state_template = '%{certification_path_statuses_ok} OR (%{certification_path_status_verifying_or_verifying_after_appeal} AND (%{user_is_manager} OR %{user_is_project_certifier})) OR (%{certification_path_status_verifying_after_appeal} AND %{scores_are_accepted})' %
            {certification_path_statuses_ok: certification_path_statuses_ok,
             certification_path_status_verifying_or_verifying_after_appeal: certification_path_status_verifying_or_verifying_after_appeal,
             user_is_manager: user_is_manager,
             user_is_project_certifier: user_is_project_certifier,
             certification_path_status_verifying_after_appeal: certification_path_status_verifying_after_appeal,
             scores_are_accepted: scores_are_accepted,
            }
        return check_scheme_mix_criterion_state_template
      else
        'true'
      end
    end

    def build_check_minimum_valid_score_query(field_name, field_table)
      check_minimum_valid_score_template = '(%{field_table}.%{field_name} >= scheme_criteria_score.minimum_valid_score)'
      check_minimum_valid_score_template % {field_table: field_table, field_name: field_name}
    end

    def build_check_certification_path_state_query(field_name)
      if field_name == :targeted_score
        minimum_certification_path_status_id = CertificationPathStatus::SUBMITTING
      elsif field_name == :submitted_score
        minimum_certification_path_status_id = CertificationPathStatus::SUBMITTING
      elsif field_name == :achieved_score
        minimum_certification_path_status_id = CertificationPathStatus::VERIFYING
      end
      check_certification_path_state_template = '(certification_paths_score.certification_path_status_id >= %{certification_path_status_id})'
      check_certification_path_state_template % {certification_path_status_id: minimum_certification_path_status_id}
    end

    def build_score_calculation_query(field_name, field_table, point_type)
      score = 'GREATEST(%{field_table}.%{field_name}::float, scheme_criteria_score.minimum_score::float)'
      maximum_score = 'scheme_criteria_score.maximum_score::float'
      criteria_weight = 'scheme_criteria_score.weight'
      incentive_weight = "(CASE #{score} WHEN -1 THEN scheme_criteria_score.incentive_weight_minus_1 WHEN 0 THEN scheme_criteria_score.incentive_weight_0 WHEN 1 THEN scheme_criteria_score.incentive_weight_1 WHEN 2 THEN scheme_criteria_score.incentive_weight_2  WHEN 3 THEN scheme_criteria_score.incentive_weight_3 ELSE 0 END)"
      scheme_weight = 'scheme_mixes_score.weight'
      if point_type == :criteria_points
        score_template = "SUM(#{score})"
      elsif point_type == :scheme_points
        # score_template = "SUM((#{score} / #{maximum_score}) * ((3.0 * (#{criteria_weight})) / 100.0) + (3.0 * #{incentive_weight} / 100.0))"
        score_template = "SUM( CASE (certificates_score.gsas_version = '2.1 issue 1') WHEN true THEN (#{score}) ELSE ((#{score} / #{maximum_score}) * ((3.0 * (#{criteria_weight})) / 100.0) + (3.0 * #{incentive_weight} / 100.0)) END)"
      elsif point_type == :certificate_points
        # score_template = "SUM(((#{score} / #{maximum_score}) * ((3.0 * (#{criteria_weight})) / 100.0) + (3.0 * #{incentive_weight} / 100.0)) * (#{scheme_weight} / 100.0))"
        score_template = "SUM( CASE (certificates_score.gsas_version = '2.1 issue 1') WHEN true THEN (#{score} * (#{scheme_weight} / 100.0)) ELSE (((#{score} / #{maximum_score}) * ((3.0 * (#{criteria_weight})) / 100.0) + (3.0 * #{incentive_weight} / 100.0)) * (#{scheme_weight} / 100.0)) END)"
      else
        raise('Unexpected point type: ' + point_type.to_s)
      end
      # build score calculation query
      score_template % {field_table: field_table, field_name: field_name}
    end

    def field_table_for_field_name(field_name)
      if field_name == :maximum_score or field_name == :minimum_score or field_name == :minimum_valid_score
        field_table = 'scheme_criteria_score'
      elsif field_name == :achieved_score or field_name == :submitted_score or field_name == :targeted_score
        field_table = 'scheme_mix_criteria_score'
      else
        raise('Unexpected score field: ' + field_name.to_s)
      end
      field_table
    end

    def base_score_query
      relation = SchemeMixCriterion
                     .from('scheme_mix_criteria as scheme_mix_criteria_score')
                     .joins('INNER JOIN scheme_criteria as scheme_criteria_score ON scheme_criteria_score.id = scheme_mix_criteria_score.scheme_criterion_id')
                     .joins('INNER JOIN scheme_mixes as scheme_mixes_score ON scheme_mixes_score.id = scheme_mix_criteria_score.scheme_mix_id')
                     .joins('INNER JOIN certification_paths as certification_paths_score ON certification_paths_score.id = scheme_mixes_score.certification_path_id')
                     .joins('INNER JOIN certificates as certificates_score ON certificates_score.id = certification_paths_score.certificate_id')
                     .joins('INNER JOIN projects ON projects.id = certification_paths_score.project_id')
      case self.name
        when CertificationPath.name, SchemeMix.name, SchemeMixCriterion.name
          relation
        when Effective::Datatables::ProjectsCertificationPaths.name
          relation
              .where('scheme_mixes_score.certification_path_id = certification_paths.id')
        else
          raise('Unsupported class: ', self.name)
      end
    end

  end
end