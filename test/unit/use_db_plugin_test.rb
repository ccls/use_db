require 'test_helper'

class UseDbPluginTest < ActiveSupport::TestCase

	test "should respond to all_use_dbs" do
		assert model_name.constantize.methods.include?('all_use_dbs')
	end

	test "should respond to debug_print" do
		assert model_name.constantize.methods.include?('debug_print')
	end

	test "should respond to debug_print=" do
		assert model_name.constantize.methods.include?('debug_print=')
	end

	test "instance should respond to use_db" do
		assert model_name.constantize.instance_methods.include?('use_db')
	end

	test "instance should respond to get_use_db_conn_spec" do
		assert model_name.constantize.instance_methods.include?('get_use_db_conn_spec')
	end

end
