class AddPasswordStuff < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :password_digest, :string
    add_column :users, :email, :string
    add_column :users, :verification_code, :string
    add_column :users, :verified_at, :datetime
    add_column :users, :last_bounce_at, :datetime
    add_column :users, :bounce_count, :integer, null: false, default: 0
    add_index :users, :verification_code, unique: true
    add_index :users, :email, unique: true

    User.includes(:emails).all.each do |u|
      u.password = SecureRandom.alphanumeric(32)
      u.verified_at = Time.now
      email = u.emails.last
      if email
        u.email = email.email
      end
      if !u.save
        raise "invalid user: " + u.errors.inspect
      end
    end
  end
end
