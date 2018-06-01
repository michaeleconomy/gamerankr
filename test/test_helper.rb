ENV["RAILS_ENV"] = "test"
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
OmniAuth.config.test_mode = true

class ActiveSupport::TestCase
  include FactoryBot::Syntax::Methods
end
