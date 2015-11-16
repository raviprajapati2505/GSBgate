class RemoveSeedUsersFromDev < ActiveRecord::Migration
  def change
    if !Rails.env.production?
      User.where(email: ['s.alayoubi@gord.qa', 'amit@digitalnexa.com']).delete_all
    end
  end
end
