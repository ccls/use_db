require 'test_helper'

class GammaTest < ActiveSupport::TestCase

	test "should create" do
#		puts Gamma.connection.current_database
		assert_difference('Gamma.count') {
			assert Gamma.create()
		}
	end

end
