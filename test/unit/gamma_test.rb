require 'test_helper'

class GammaTest < ActiveSupport::TestCase

	test "should create" do
		assert_difference("#{model_name}.count") {
			model_name.constantize.create
		}
	end

	test "should be in gamma database" do
		config = model_name.constantize.connection.instance_variable_get('@config')
		database = config[:database]
		arconfig = model_name.constantize.configurations["gamma_test"]['database']
		assert_match(arconfig,database)
	end

	test "should be in all_use_dbs" do
		UseDbPlugin.all_use_dbs.include?(model_name.constantize)
	end

	test "should use_db" do
		assert model_name.constantize.uses_db?
	end

end
