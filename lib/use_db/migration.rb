module UseDb::Migration

	def self.included(base)
		unless base.respond_to?(:method_missing_without_connection_swap)
			base.extend(ClassMethods)
			base.class_eval do
				class << self
					alias_method_chain :method_missing, :connection_swap
				end
			end 
		end 
	end

	module ClassMethods

		def method_missing_with_connection_swap(method, *arguments, &block)
			say_with_time "#{method}(#{arguments.map { |a| a.inspect }.join(", ")})" do
				arguments[0] = ActiveRecord::Migrator.proper_table_name(arguments.first
					) unless arguments.empty? || method == :execute
				if (self.respond_to?(:database_model))
					write "Using custom database model's connection (#{self.database_model}) for this migration"
					eval("#{self.database_model}.connection.send(method, *arguments, &block)")
				else
					ActiveRecord::Base.connection.send(method, *arguments, &block)
#					method_missing_without_connection_swap(method, *arguments, &block)
				end
			end
		end

		def uses_db?
			true
		end

	end

end
ActiveRecord::Migration.send(:include,UseDb::Migration)

module UseDb::Migrator

	def self.included(base)
		unless base.respond_to?(:get_all_versions_without_connection_swap)
			base.extend(ClassMethods)
			base.alias_method_chain( :record_version_state_after_migrating, :connection_swap
				) unless base.methods.include?(:record_version_state_after_migrating_without_connection_swap)
			base.class_eval do
				class << self
					alias_method_chain :get_all_versions, :connection_swap
				end
			end 
		end 
	end

	module ClassMethods

		def get_all_versions_with_connection_swap
#			puts "in use_db get_all_versions"
#			Base.connection.select_values("SELECT version FROM #{schema_migrations_table_name}").map(&:to_i).sort
			UseDbPlugin.all_use_dbs.collect(&:connection).collect{|c|
				c.initialize_schema_migrations_table	# in case it doesn't exist
				c.select_values("SELECT version FROM #{schema_migrations_table_name}").map(&:to_i)
			}.flatten.uniq.sort
		end

	end

	def record_version_state_after_migrating_with_connection_swap(version)
		just_migrated = migrations.detect { |m| m.version == version }
		load(just_migrated.filename)
		migration_model = just_migrated.name.constantize
		if migration_model.respond_to?(:database_model)
			ar_model = migration_model.database_model.constantize
			ar_model.connection.initialize_schema_migrations_table
			sm_table = self.class.schema_migrations_table_name
			@migrated_versions ||= []
			if down?
				@migrated_versions.delete(version.to_i)
				ar_model.connection.update("DELETE FROM #{sm_table} WHERE version = '#{version}'")
			else
				@migrated_versions.push(version.to_i).sort!
				ar_model.connection.insert("INSERT INTO #{sm_table} (version) VALUES ('#{version}')")
			end
		else
			record_version_state_after_migrating_without_connection_swap(version)
		end
	end

end
ActiveRecord::Migrator.send(:include,UseDb::Migrator)
