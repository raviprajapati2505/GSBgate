class UpdateUserEmails < ActiveRecord::Migration[5.2]
  def up
    # as email is set to uniq, change email of user who has multiple account with same email.
    emails = User.group("users.email").having("COUNT(users.email) > 1").pluck(:email)

    emails.each do |email|
      users = User.where(email: email)
      users.each_with_index do |user, index|
        begin
          unless index == 0
            updated_email = email.split('@').join("+#{index}@")
            user.update_columns(email: updated_email)
          end
        rescue => exception
          puts "-------- Failed to update #{email} -----------"
        end
      end
    end
  end

  def down
    puts "-------- Irreversible Migration -----------"
  end
end
