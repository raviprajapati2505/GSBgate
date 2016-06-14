class RemoveImagesFromCriterionTexts < ActiveRecord::Migration
  def change
    SchemeCriterionText.update_all("html_text = regexp_replace(html_text, '<img.*/>', '')")
  end
end
