class UseDbTest

	extend UseDbPlugin

	def self.other_databases
		use_db_config = (defined?(USE_DB_CONFIG)) ? USE_DB_CONFIG : "#{RAILS_ROOT}/config/use_db.yml"
		YAML.load(File.read(use_db_config)).values.collect(&:symbolize_keys!)
	end

	def self.prepare_test_db(options)
		schema_dump(options)
		schema_load(options)
#		dump_db_structure(options)
#		purge_db(options)
#		clone_db_structure(options)
#		ENV['RAILS_ENV'] = 'test'
#    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
#    ActiveRecord::Migrator.migrate("db/migrate/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
	end
	
	def self.schema_dump(options)
		#	puts "In schema_dump"
		options_dup = options.dup
		options_dup[:rails_env] = "development"		
		conn_spec = get_use_db_conn_spec(options_dup)
		test_class = setup_test_model(options[:prefix], options[:suffix], "ForSchemaDump")
		test_class.establish_connection(conn_spec)
		require 'active_record/schema_dumper'
		File.open(schema_file(options), "w") do |file|
			ActiveRecord::SchemaDumper.dump(test_class.connection, file)
		end
	end

	def self.schema_load(options)
		#	puts "In schema_load"
		options_dup = options.dup
#		options_dup[:rails_env] = "development"		
		conn_spec = get_use_db_conn_spec(options_dup)
		ActiveRecord::Base.establish_connection(conn_spec)
#		ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations["#{options[:prefix]}test"])
		file = schema_file(options)
		if File.exists?(file)
			#	puts "loading #{file}"
			ENV['SCHEMA'] = file
#			require 'rake'
#			require 'rake/testtask'
#			require 'rake/rdoctask'
#			require 'tasks/rails'
			ActiveRecord::Schema.verbose = false
			load(file)
#			Rake::Task["db:schema:load"].invoke
#			Rake::Task["db:schema:load"].reenable
			ActiveRecord::Base.connection.disconnect!
			ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations["test"])
		else
			abort %{#{file} doesn't exist yet. Run "rake db:migrate" to create it then try again. If you do not intend to use a database, you should instead alter #{RAILS_ROOT}/config/environment.rb to prevent active_record from loading: config.frameworks -= [ :active_record ]}
		end
	end

	def self.dump_db_structure(options)
		options_dup = options.dup
		options_dup[:rails_env] = "development"		
		conn_spec = get_use_db_conn_spec(options_dup)
		#establish_connection(conn_spec)
		
		test_class = setup_test_model(options[:prefix], options[:suffix], "ForDumpStructure")
		
		# puts "Dumping DB structure #{test_class.inspect}..."
					
		case conn_spec["adapter"]
			when "mysql", "oci", "oracle"
				test_class.establish_connection(conn_spec)
				File.open(structure_sql(options), "w+") { |f| f << test_class.connection.structure_dump }

			when "sqlite", "sqlite3"
				config = test_class.establish_connection(conn_spec).connection.instance_variable_get(:@config)
				dbfile = config[:database]
				command = "#{conn_spec["adapter"]} #{dbfile} .schema > #{structure_sql(options)}"
				#puts "RUBY:#{command}"
				`#{command}`

=begin			when "postgresql"
				ENV['PGHOST']		 = abcs[RAILS_ENV]["host"] if abcs[RAILS_ENV]["host"]
				ENV['PGPORT']		 = abcs[RAILS_ENV]["port"].to_s if abcs[RAILS_ENV]["port"]
				ENV['PGPASSWORD'] = abcs[RAILS_ENV]["password"].to_s if abcs[RAILS_ENV]["password"]
				search_path = abcs[RAILS_ENV]["schema_search_path"]
				search_path = "--schema=#{search_path}" if search_path
				`pg_dump -i -U "#{abcs[RAILS_ENV]["username"]}" -s -x -O -f db/#{RAILS_ENV}_structure.sql #{search_path} #{abcs[RAILS_ENV]["database"]}`
				raise "Error dumping database" if $?.exitstatus == 1
			when "sqlserver"
				`scptxfr /s #{abcs[RAILS_ENV]["host"]} /d #{abcs[RAILS_ENV]["database"]} /I /f db\\#{RAILS_ENV}_structure.sql /q /A /r`
				`scptxfr /s #{abcs[RAILS_ENV]["host"]} /d #{abcs[RAILS_ENV]["database"]} /I /F db\ /q /A /r`
			when "firebird"
				set_firebird_env(abcs[RAILS_ENV])
				db_string = firebird_db_string(abcs[RAILS_ENV])
				sh "isql -a #{db_string} > db/#{RAILS_ENV}_structure.sql"
=end				
			else
				raise "Task not supported by '#{conn_spec["adapter"]}'"
		end

		#if test_class.connection.supports_migrations?
		#	File.open("db/#{RAILS_ENV}_structure.sql", "a") { |f| f << ActiveRecord::Base.connection.dump_schema_information }
		#end
		
		test_class.connection.disconnect!
	end
	
	def self.clone_db_structure(options)
		options_dup = options.dup
		conn_spec = get_use_db_conn_spec(options_dup)
		#establish_connection(conn_spec)
		
		test_class = setup_test_model(options[:prefix], options[:suffix], "ForClone")
		
	 # puts "Cloning DB structure #{test_class.inspect}..."
		
		case conn_spec["adapter"]
			when "mysql"
				test_class.connection.execute('SET foreign_key_checks = 0')
				IO.readlines(structure_sql(options)).join.split("\n\n").each do |table|
					test_class.connection.execute(table)
				end
			when "oci", "oracle"
				IO.readlines(structure_sql(options)).join.split(";\n\n").each do |ddl|

					test_class.connection.execute(ddl)
				end

			when "sqlite","sqlite3"
				config = test_class.establish_connection(conn_spec).connection.instance_variable_get(:@config)
				dbfile = config[:database]
				command = "#{conn_spec["adapter"]} #{dbfile} < #{structure_sql(options)}"
				#puts "RUBY:#{command}"
				`#{command}`



=begin			when "postgresql"
				ENV['PGHOST']		 = abcs["test"]["host"] if abcs["test"]["host"]
				ENV['PGPORT']		 = abcs["test"]["port"].to_s if abcs["test"]["port"]
				ENV['PGPASSWORD'] = abcs["test"]["password"].to_s if abcs["test"]["password"]
				`psql -U "#{abcs["test"]["username"]}" -f db/#{RAILS_ENV}_structure.sql #{abcs["test"]["database"]}`
			when "sqlserver"
				`osql -E -S #{abcs["test"]["host"]} -d #{abcs["test"]["database"]} -i db\\#{RAILS_ENV}_structure.sql`
			when "firebird"
				set_firebird_env(abcs["test"])
				db_string = firebird_db_string(abcs["test"])
				sh "isql -i db/#{RAILS_ENV}_structure.sql #{db_string}"
=end
			else
				raise "Task not supported by '#{conn_spec["adapter"]}'"
		end
		
		test_class.connection.disconnect!		
	end
	
	def self.purge_db(options)
		options_dup = options.dup
		conn_spec = get_use_db_conn_spec(options_dup)
		#establish_connection(conn_spec)
		
		test_class = setup_test_model(options[:prefix], options[:suffix], "ForPurge")
		
		case conn_spec["adapter"]
			when "mysql"
				test_class.connection.recreate_database(conn_spec["database"])
			when "oci", "oracle"
				test_class.connection.structure_drop.split(";\n\n").each do |ddl|
					test_class.connection.execute(ddl)
				end
			when "firebird"
				test_class.connection.recreate_database!

			when "sqlite","sqlite3"
				dbfile = test_class.connection.instance_variable_get(:@config)[:database]
				File.delete(dbfile) if File.exist?(dbfile)


=begin
			when "postgresql"
				ENV['PGHOST']		 = abcs["test"]["host"] if abcs["test"]["host"]
				ENV['PGPORT']		 = abcs["test"]["port"].to_s if abcs["test"]["port"]
				ENV['PGPASSWORD'] = abcs["test"]["password"].to_s if abcs["test"]["password"]
				enc_option = "-E #{abcs["test"]["encoding"]}" if abcs["test"]["encoding"]

				ActiveRecord::Base.clear_active_connections!
				`dropdb -U "#{abcs["test"]["username"]}" #{abcs["test"]["database"]}`
				`createdb #{enc_option} -U "#{abcs["test"]["username"]}" #{abcs["test"]["database"]}`
			when "sqlserver"
				dropfkscript = "#{abcs["test"]["host"]}.#{abcs["test"]["database"]}.DP1".gsub(/\\/,'-')
				`osql -E -S #{abcs["test"]["host"]} -d #{abcs["test"]["database"]} -i db\\#{dropfkscript}`
				`osql -E -S #{abcs["test"]["host"]} -d #{abcs["test"]["database"]} -i db\\#{RAILS_ENV}_structure.sql`
=end
			else
				raise "Task not supported by '#{conn_spec["adapter"]}'"
		end
		
		test_class.connection.disconnect!				
	end

	def self.setup_test_model(prefix="", suffix="", model_suffix="", rails_env=RAILS_ENV)
		prefix ||= ""
		suffix ||= ""
		model_name = "TestModel#{prefix.camelize}#{suffix.camelize}#{model_suffix}".gsub("_","").gsub("-","")
		return eval(model_name) if eval("defined?(#{model_name})")
		create_test_model(model_name, prefix, suffix, rails_env)
		return eval(model_name)
	end

	def self.structure_sql(options)
		"#{RAILS_ROOT}/db/#{RAILS_ENV}_#{options[:prefix]}_#{options[:suffix]}_structure.sql"
	end

	def self.schema_file(options)
		"#{RAILS_ROOT}/db/#{RAILS_ENV}_#{options[:prefix]}_#{options[:suffix]}_schema.rb"
	end

end
