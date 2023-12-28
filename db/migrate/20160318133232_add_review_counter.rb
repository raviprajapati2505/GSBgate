class AddReviewCounter < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_mix_criteria, :review_count, :integer, default: 0
    add_column :certification_paths, :max_review_count, :integer, default: 2
  end
end
