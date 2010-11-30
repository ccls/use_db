require 'test_helper'

class BetaTest < ActiveSupport::TestCase

	test "should create" do
#		puts Beta.connection.current_database
		assert_difference('Beta.count') {
			assert Beta.create()
		}
	end

end
