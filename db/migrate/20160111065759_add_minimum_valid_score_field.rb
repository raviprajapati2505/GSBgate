class AddMinimumValidScoreField < ActiveRecord::Migration
  def up
    add_column :scheme_criteria, :minimum_score, :integer
    add_column :scheme_criteria, :maximum_score, :integer
    add_column :scheme_criteria, :minimum_valid_score, :integer
    SchemeCriterion.update_all("minimum_score = CAST(substring(scores, '^(?:---\\n-\\s)(-?\\d)(?:\\s)') AS float)")
    SchemeCriterion.update_all("maximum_score = CAST(substring(scores, '.\n$') AS float)")
    SchemeCriterion.update_all('minimum_valid_score = minimum_score')
    SchemeCriterion.joins(:scheme_category).where(scheme_categories: {code: 'E'}).update_all('minimum_valid_score = 0')
    SchemeCriterion.joins(:scheme_category).where(scheme_categories: {code: 'W'}).update_all('minimum_valid_score = 0')
  end

  def down
    remove_column :scheme_criteria, :minimum_score
    remove_column :scheme_criteria, :maximum_score
    remove_column :scheme_criteria, :minimum_valid_score
  end
end
