class AddPcrReviewDraftToSchemeMixCriteria < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_mix_criteria, :pcr_review_draft, :text
  end
end
