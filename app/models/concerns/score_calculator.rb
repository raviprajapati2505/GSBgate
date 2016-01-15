module ScoreCalculator
  extend ActiveSupport::Concern

  POINT_TYPES = [:criteria_points, :scheme_points, :certificate_points]
  SCORE_FIELDS = [:achieved_score, :submitted_score, :targeted_score, :maximum_score, :minimum_score]
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
      # determine table for field name
      if field_name == :maximum_score or field_name == :minimum_score
        field_table = 'scheme_criteria_score'
      elsif field_name == :achieved_score or field_name == :submitted_score or field_name == :targeted_score
        field_table = 'scheme_mix_criteria_score'
      else
        raise('Unexpected score field: ' + field_name.to_s)
      end

      # determine template
      if point_type == :criteria_points
        score_template = 'SUM(GREATEST(%{field_table}.%{field_name}::float, scheme_criteria_score.minimum_score::float))'
      elsif point_type == :scheme_points
        score_template = 'SUM(((GREATEST(%{field_table}.%{field_name}::float, scheme_criteria_score.minimum_score::float) / scheme_criteria_score.maximum_score::float) * ((3.0 * (scheme_criteria_score.weight + scheme_criteria_score.incentive_weight)) / 100.0)))'
      elsif point_type == :certificate_points
        score_template = 'SUM(((GREATEST(%{field_table}.%{field_name}::float, scheme_criteria_score.minimum_score::float) / scheme_criteria_score.maximum_score::float) * ((3.0 * (scheme_criteria_score.weight + scheme_criteria_score.incentive_weight)) / 100.0)  * (scheme_mixes_score.weight / 100.0)))'
      else
        raise('Unexpected point type: ' + point_type.to_s)
      end
      # build complete query string using parts
      score_query = score_template % {field_table: field_table, field_name: field_name}

      if field_name == :achieved_score or field_name == :submitted_score or field_name == :targeted_score
        # Check if the score is not below the minimum required valid score
        # -- first compare
        # -- then convert to a number, so we can use an aggregate function
        # -- then compare the aggregate result
        # -- returning NULL if there was at least 1 invalid scheme mix criterion
        # -- OR return the actual score sum query
        validation_template = 'CASE MAX(CASE(%{field_table}.%{field_name} < scheme_criteria_score.minimum_valid_score) WHEN true then 1 else 0 end) WHEN 1 THEN null ELSE %{score_query} end'
      else
        validation_template = '%{score_query}'
      end
      validation_query = validation_template % {field_table: field_table, field_name: field_name, score_query: score_query}

      # alias part
      field_alias = ' as ' + field_alias unless field_alias.empty?

      return '%{validation_query}%{field_alias}' % {validation_query: validation_query, field_alias: field_alias}
    end

    def base_score_query
      relation = SchemeMixCriterion
                     .from('scheme_mix_criteria as scheme_mix_criteria_score')
                     .joins('INNER JOIN scheme_criteria as scheme_criteria_score ON scheme_criteria_score.id = scheme_mix_criteria_score.scheme_criterion_id')
                     .joins('INNER JOIN scheme_mixes as scheme_mixes_score ON scheme_mixes_score.id = scheme_mix_criteria_score.scheme_mix_id')
                     .joins('INNER JOIN certification_paths as certification_paths_score ON certification_paths_score.id = scheme_mixes_score.certification_path_id')
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