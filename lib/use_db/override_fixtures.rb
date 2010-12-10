#
#	Put the fixtures in the correct database
#
module UseDb::Fixtures

	def self.included(base)
		unless base.respond_to?(:read_fixture_files_without_connection_set)
			base.alias_method_chain :read_fixture_files, :connection_set
		end
	end

	def read_fixture_files_with_connection_set
		@connection = (model_class||ActiveRecord::Base).connection
		read_fixture_files_without_connection_set
	end

end
Fixtures.send(:include,UseDb::Fixtures)
