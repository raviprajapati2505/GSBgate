class AddVerticalAlignToSchemeCriterionTexts < ActiveRecord::Migration[5.2]
  def change
    SchemeCriterionText.where("html_text LIKE '%<td rowspan=\"2\">%'").each do |sct|
      sct.update_column(:html_text, sct.html_text.gsub('<td rowspan="2">', '<td rowspan="2" style="vertical-align:middle;">'))
    end
  end
end
