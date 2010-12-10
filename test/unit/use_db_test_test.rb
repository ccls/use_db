require 'test_helper'

class UseDbTestTest < ActiveSupport::TestCase

	test "should have 3 other database" do
		assert_equal 3, model_name.constantize.other_databases.length
	end

	test "should respond to other_databases" do
		assert model_name.constantize.respond_to?(:other_databases)
	end

	test "should respond to prepare_test_db" do
		assert model_name.constantize.respond_to?(:prepare_test_db)
	end

	test "should respond to schema_dump" do
		assert model_name.constantize.respond_to?(:schema_dump)
	end

	test "should respond to schema_load" do
		assert model_name.constantize.respond_to?(:schema_load)
	end

	test "should respond to setup_test_model" do
		assert model_name.constantize.respond_to?(:setup_test_model)
	end

	test "should respond to schema_file" do
		assert model_name.constantize.respond_to?(:schema_file)
	end

end
