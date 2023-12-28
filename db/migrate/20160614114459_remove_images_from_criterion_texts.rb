class RemoveImagesFromCriterionTexts < ActiveRecord::Migration[4.2]
  def change
    SchemeCriterionText.update_all("html_text = regexp_replace(html_text, '<img.*/>', '')")
  end
end
