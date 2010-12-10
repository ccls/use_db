require 'test_helper'

class ActiveRecord::BaseTest < ActiveSupport::TestCase

	test "should respond to use_db" do
		assert ActiveRecord::Base.respond_to?(:use_db)
	end

end
