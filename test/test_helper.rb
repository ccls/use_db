ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'

$:.unshift "#{RAILS_ROOT}/test/"
#UseDbPlugin.debug_print = true

class ActiveSupport::TestCase
	unless defined?(CLONED_SEC_DB_FOR_TEST)
		#	autotest does NOT run 'rake db:test:prepare', but with no options
		#	this works just fine.  It is unnecessary if using 'rake test'.
		UseDbTest.prepare_test_db
		UseDbTest.prepare_test_db(:prefix => "alpha_")
		UseDbTest.prepare_test_db(:prefix => "beta_")
		UseDbTest.prepare_test_db(:prefix => "gamma_")
		CLONED_SEC_DB_FOR_TEST = true
	end

	self.use_transactional_fixtures = true
	self.use_instantiated_fixtures  = false
	fixtures :all
end
