require 'test_helper'

class GammaTest < ActiveSupport::TestCase

	test "should create" do
#puts Gamma.inspect
#puts Gamma.new.inspect
#puts Gamma.connection.inspect
#puts Gamma.connection.current_database
#		puts Gamma.connection.current_database
		assert_difference('Gamma.count') {
#			x=Gamma.new()
#			x.save
#puts x.inspect
			Gamma.create
		}
	end

end
