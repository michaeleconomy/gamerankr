OmniAuth.config.test_mode = true

class FbGraph2::User
  @@default_values = {
    email: "foo@foo.com",
    id: 5,
    name: "Bob hampkins"
  }

  def self.stub(key, value)
    @@default_values[key] = value
  end
  def fetch(f)
    m = MockFBResult.new
    m.email = @@default_values[:email]
    m.id = @@default_values[:id]
    m.name = @@default_values[:name]
    m
  end

  class MockFBResult
    attr_accessor :email, :id, :name
  end
end