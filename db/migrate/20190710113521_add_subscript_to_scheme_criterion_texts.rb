class AddSubscriptToSchemeCriterionTexts < ActiveRecord::Migration[5.2]
  def change
    ['del', 'use-as built', 'use-as operated', 'use-benchmark', 'benchmark'].each do |string_to_sub|
      SchemeCriterionText.where("html_text LIKE '%span>#{string_to_sub}</span%'").each do |sct|
        sct.update_column(:html_text, sct.html_text.gsub("<span>#{string_to_sub}</span>", "<sub>#{string_to_sub}</sub>"))
      end
    end
  end
end
