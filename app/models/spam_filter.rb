class SpamFilter < ApplicationRecord
	def self.filter(s)
		s = s.downcase
		all.collect{|f| f.keyword.downcase }.any?{|keyword| s.include?(keyword)}
	end
end
