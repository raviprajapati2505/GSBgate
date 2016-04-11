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
      if field_name == :achieved_score
        # Note: scored is a one of score_awarded, score_downgraded, score_upgraded, score_minimal
        scheme_mix_criterion_scored = SchemeMixCriterion::statuses[:score_minimal]
        scheme_mix_criterion_scored_after_appeal = SchemeMixCriterion::statuses[:score_minimal_after_appeal]
        # Certification path status
        certification_path_status_verifying = CertificationPathStatus::VERIFYING
        certification_path_status_verifying_after_appeal = CertificationPathStatus::VERIFYING_AFTER_APPEAL
        included_roles = [ProjectsUser::roles[:certification_manager], ProjectsUser::roles[:certifier]]
        check_scheme_mix_criterion_state_template = '(scheme_mix_criteria_score.status <= %{scheme_mix_criterion_scored} AND certification_paths_score.certification_path_status_id = %{certification_path_status_verifying}) OR (scheme_mix_criteria_score.status <= %{scheme_mix_criterion_scored_after_appeal} AND certification_paths_score.certification_path_status_id = %{certification_path_status_verifying_after_appeal}) OR EXISTS(SELECT user_id FROM projects_users WHERE projects_users.project_id = projects.id AND projects_users.user_id = %{user_id} AND projects_users.role IN (%{project_roles})) OR NOT EXISTS(SELECT user_id FROM projects_users WHERE projects_users.user_id = %{user_id})'
        check_scheme_mix_criterion_state_template % {scheme_mix_criterion_scored: scheme_mix_criterion_scored,
                                                     scheme_mix_criterion_scored_after_appeal: scheme_mix_criterion_scored_after_appeal,
                                                     certification_path_status_verifying: certification_path_status_verifying,
                                                     certification_path_status_verifying_after_appeal: certification_path_status_verifying_after_appeal,
                                                     user_id: User.current.id,
                                                     project_roles: included_roles.join(', ')}
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
      if point_type == :criteria_points
        score_template = 'SUM(GREATEST(%{field_table}.%{field_name}::float, scheme_criteria_score.minimum_score::float))'
      elsif point_type == :scheme_points
        score_template = 'SUM(((GREATEST(%{field_table}.%{field_name}::float, scheme_criteria_score.minimum_score::float) / scheme_criteria_score.maximum_score::float) * ((3.0 * (scheme_criteria_score.weight + scheme_criteria_score.incentive_weight)) / 100.0)))'
      elsif point_type == :certificate_points
        score_template = 'SUM(((GREATEST(%{field_table}.%{field_name}::float, scheme_criteria_score.minimum_score::float) / scheme_criteria_score.maximum_score::float) * ((3.0 * (scheme_criteria_score.weight + scheme_criteria_score.incentive_weight)) / 100.0)  * (scheme_mixes_score.weight / 100.0)))'
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