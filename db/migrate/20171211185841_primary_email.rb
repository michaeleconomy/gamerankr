class PrimaryEmail < ActiveRecord::Migration[5.1]
  def change
    add_column :emails, :primary, :boolean, :null => false, :default => :false

    User.all.each do |u|
      email = u.emails.first
      if email
        email.update(:primary => true)
      end
    end
  end
end
