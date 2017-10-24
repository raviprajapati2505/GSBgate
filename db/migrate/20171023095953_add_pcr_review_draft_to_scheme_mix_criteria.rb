class AddPcrReviewDraftToSchemeMixCriteria < ActiveRecord::Migration
  def change
    add_column :scheme_mix_criteria, :pcr_review_draft, :text
  end
end
