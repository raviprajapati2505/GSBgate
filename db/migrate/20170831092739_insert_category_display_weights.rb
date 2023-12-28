class InsertCategoryDisplayWeights < ActiveRecord::Migration[4.2]
  def change
    categories = SchemeCategory.where(display_weight: nil)
    categories.each do |category|
      case category.code
        when 'UC'
          category.display_weight = 10
        when 'S'
          category.display_weight = 20
        when 'E'
          category.display_weight = 30
        when 'W'
          category.display_weight = 40
        when 'M'
          category.display_weight = 50
        when 'OE'
          category.display_weight = 60
        when 'SD'
          category.display_weight = 70
        when 'MO'
          category.display_weight = 80
      end
      category.save!
    end
  end
end
