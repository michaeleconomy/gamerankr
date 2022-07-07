class PasswordResetRequest < ApplicationRecord
	belongs_to :user

	@expiration = 12.hours

	def self.get(code)
		where(code: code).where("updated_at > ?", @expiration.ago).first
	end
end
