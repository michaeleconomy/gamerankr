class IndexPwResetRequestsOnCode < ActiveRecord::Migration[7.0]
  def change
    add_index :password_reset_requests, :code, unique: true
  end
end
