require 'test_helper'

class AlphaTest < ActiveSupport::TestCase

	test "should create" do
		assert_difference("#{model_name}.count") {
			assert model_name.constantize.create()
		}
	end

	test "should be in alpha database" do
		config = model_name.constantize.connection.instance_variable_get('@config')
		database = config[:database]
		arconfig = model_name.constantize.configurations["alpha_test"]['database']
		assert_match(arconfig,database)
	end

	test "should be in all_use_dbs" do
		UseDbPlugin.all_use_dbs.include?(model_name.constantize)
	end

	test "should use_db" do
		assert model_name.constantize.uses_db?
	end

	test "should have 2 records" do
		assert_equal 2, model_name.constantize.all.length
	end

end
