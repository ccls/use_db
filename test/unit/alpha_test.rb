require 'test_helper'

class AlphaTest < ActiveSupport::TestCase

	test "should create" do
#		puts Alpha.connection.current_database
		assert_difference('Alpha.count') {
			assert Alpha.create()
		}
	end

end
