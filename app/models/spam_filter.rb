class SpamFilter < ApplicationRecord
	def self.filter(s)
		all.collect(&:keyword).any?{|keyword| s.include?(keyword)}
	end
end
