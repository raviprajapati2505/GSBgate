class AddSeedUsers < ActiveRecord::Migration[4.2]
  def change
    User.create!(email: 's.alayoubi@gord.qa', password: 'password', password_confirmation: 'password', role: :user)
    User.create!(email: 'amit@digitalnexa.com', password: 'password', password_confirmation: 'password', role: :user)
  end
end
