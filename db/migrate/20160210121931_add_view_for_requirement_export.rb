class AddViewForRequirementExport < ActiveRecord::Migration
  def up
    execute <<-SQL
      CREATE VIEW criteria_summary AS
        SELECT
        certificates.gsas_version AS "version",
        certificates.name AS "certificate",
        schemes.name AS "scheme",
        schemes.renovation AS "is a renovation",
        scheme_categories.name AS "category",
        concat(scheme_categories.code, '.', scheme_criteria.number) AS "criterion number",
        scheme_criteria.name AS "criterion name"
        FROM certificates
        LEFT JOIN schemes ON certificates.id = schemes.certificate_id
        LEFT JOIN scheme_categories ON schemes.id = scheme_categories.scheme_id
        LEFT JOIN scheme_criteria ON scheme_categories.id = scheme_criteria.scheme_category_id
        ORDER BY certificates.gsas_version, certificates.display_weight, schemes.renovation, schemes.name, scheme_categories.display_weight, scheme_criteria.number;
    SQL
  end

  def down
    execute 'DROP VIEW criteria_summary'
  end
end
