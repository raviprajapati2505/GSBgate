class MakeAllTablesInSchemeCriterionTextsResponsive < ActiveRecord::Migration[5.2]
  def change
    SchemeCriterionText.where("html_text LIKE '%<table%' OR html_text LIKE '<table%'").each do |sct|
      sct.update_column(:html_text, sct.html_text.gsub("<table", "<div class=\"table-responsive\"><table"))
      sct.update_column(:html_text, sct.html_text.gsub("</table>", "</table></div>"))
    end
  end
end
