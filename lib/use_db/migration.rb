module ActiveRecord
	class Migration
		class << self
			def method_missing(method, *arguments, &block)
				say_with_time "#{method}(#{arguments.map { |a| a.inspect }.join(", ")})" do
					arguments[0] = Migrator.proper_table_name(arguments.first) unless arguments.empty? || method == :execute
					if (self.respond_to?(:database_model))
						write "Using custom database model's connection (#{self.database_model}) for this migration"
						eval("#{self.database_model}.connection.send(method, *arguments, &block)")
					else
						ActiveRecord::Base.connection.send(method, *arguments, &block)
					end
				end
			end

			def uses_db?
				true
			end
		end
	end
	class Migrator
		class << self
			def get_all_versions
#				puts "in use_db get_all_versions"
#				Base.connection.select_values("SELECT version FROM #{schema_migrations_table_name}").map(&:to_i).sort
				UseDbPlugin.all_use_dbs.collect(&:connection).collect{|c|
					c.initialize_schema_migrations_table	# in case it doesn't exist
					c.select_values("SELECT version FROM #{schema_migrations_table_name}").map(&:to_i)
				}.flatten.uniq.sort
			end
		end
	end
end

#class ActiveRecord::ConnectionAdapters::ConnectionHandler
#	def retrieve_connection_pool_with_diff_conn(klass)
##		klass = ($my_klass.nil?)? klass : $my_klass
##puts klass
#		retrieve_connection_pool_without_diff_conn(klass)
##		$my_klass = nil
#	end
#	alias_method_chain :retrieve_connection_pool, :diff_conn
#end

#	This is nice, but unnecessary
#class ActiveRecord::Migrator
#	def record_version_state_after_migrating_with_connection_swap(version)
#		just_migrated = migrations.detect { |m| m.version == version }
#		load(just_migrated.filename)
#		migration_model = just_migrated.name.constantize
#		if migration_model.respond_to?(:database_model)
##$my_klass = migration_model.database_model.constantize
##puts $my_klass.name
#			ar_model = migration_model.database_model.constantize
#			ar_model.connection.initialize_schema_migrations_table
#			sm_table = self.class.schema_migrations_table_name
#			@migrated_versions ||= []
#			if down?
#				@migrated_versions.delete(version.to_i)
#				ar_model.connection.update("DELETE FROM #{sm_table} WHERE version = '#{version}'")
#			else
#				@migrated_versions.push(version.to_i).sort!
#				ar_model.connection.insert("INSERT INTO #{sm_table} (version) VALUES ('#{version}')")
#			end
#		else
#			record_version_state_after_migrating_without_connection_swap(version)
#		end
#	end
#	alias_method_chain :record_version_state_after_migrating, :connection_swap
#end
