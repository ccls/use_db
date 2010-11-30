require 'test_helper'

class NormalTest < ActiveSupport::TestCase

	test "should create" do
#		puts Normal.connection.current_database
		assert_difference('Normal.count') {
			assert Normal.create()
		}
	end

end
