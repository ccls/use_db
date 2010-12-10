#
#	setup and teardown fixtures in all databases
#
module UseDb::TestFixtures

	def self.included(base)
		base.alias_method_chain :setup_fixtures, :use_db
		base.alias_method_chain :teardown_fixtures, :use_db
	end

	def setup_fixtures_with_use_db
		UseDbPlugin.all_use_dbs.collect do |klass|
			return unless defined?(ActiveRecord) && !ActiveRecord::Base.configurations.blank?

			if pre_loaded_fixtures && !use_transactional_fixtures
				raise RuntimeError, 'pre_loaded_fixtures requires use_transactional_fixtures'
			end 

			@fixture_cache = {}
			@@already_loaded_fixtures ||= {}

			# Load fixtures once and begin transaction.
			if run_in_transaction?
				if @@already_loaded_fixtures[self.class]
					@loaded_fixtures = @@already_loaded_fixtures[self.class]
				else
					load_fixtures
					@@already_loaded_fixtures[self.class] = @loaded_fixtures
				end 
				klass.connection.increment_open_transactions
				klass.connection.transaction_joinable = false
				klass.connection.begin_db_transaction
			# Load fixtures for every test.
			else
				Fixtures.reset_cache
				@@already_loaded_fixtures[self.class] = nil 
				load_fixtures
			end 

			# Instantiate fixtures for every test if requested.
			instantiate_fixtures if use_instantiated_fixtures
		end
	end

	def teardown_fixtures_with_use_db
		UseDbPlugin.all_use_dbs.collect do |klass|
			return unless defined?(ActiveRecord) && !ActiveRecord::Base.configurations.blank?

			unless run_in_transaction?
				Fixtures.reset_cache
			end

			# Rollback changes if a transaction is active.
			if run_in_transaction? && klass.connection.open_transactions != 0
				klass.connection.rollback_db_transaction
				klass.connection.decrement_open_transactions
			end
			klass.clear_active_connections!
		end
	end

end
ActiveRecord::TestFixtures.send(:include,UseDb::TestFixtures)
