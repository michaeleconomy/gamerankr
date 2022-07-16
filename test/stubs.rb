OmniAuth.config.test_mode = true

class FbGraph2::User
	def fetch(f)
		MockFBResult.new
	end

	class MockFBResult
		attr_accessor :email, :id, :name
		def initialize
			@email = "foo@foo.com"
			@id = 5
			@name ="Bob Hampkins"
		end
	end
end