class UseDbTest

	extend UseDbPlugin

	def self.other_databases
		use_db_config = (defined?(USE_DB_CONFIG)) ? USE_DB_CONFIG : "#{RAILS_ROOT}/config/use_db.yml"
		YAML.load(File.read(use_db_config)).values.collect(&:symbolize_keys!)
	end

	def self.prepare_test_db(options={})
		schema_dump(options)
		schema_load(options)
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
		conn_spec = get_use_db_conn_spec(options_dup)
		ActiveRecord::Base.establish_connection(conn_spec)
		file = schema_file(options)
#	database.rake suggests that I should purge first, but why?
#	the schema is :force => true and will wipe everything out anyway.
#	using schema seems a better option than to the DSL that it came from.
		if File.exists?(file)
			#	puts "loading #{file}"
			ActiveRecord::Schema.verbose = UseDbPlugin.debug_print
			load(file)
			ActiveRecord::Base.connection.disconnect!
			ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations["test"])
		else
			abort %{#{file} doesn't exist yet. Run "rake db:migrate" to create it then try again. If you do not intend to use a database, you should instead alter #{RAILS_ROOT}/config/environment.rb to prevent active_record from loading: config.frameworks -= [ :active_record ]}
		end
	end

	def self.setup_test_model(prefix="", suffix="", model_suffix="", rails_env=RAILS_ENV)
		prefix ||= ""
		suffix ||= ""
		model_name = "TestModel#{prefix.camelize}#{suffix.camelize}#{model_suffix}".gsub("_","").gsub("-","")
		return eval(model_name) if eval("defined?(#{model_name})")
		create_test_model(model_name, prefix, suffix, rails_env)
		return eval(model_name)
	end

	def self.schema_file(options)
		"#{RAILS_ROOT}/db/#{RAILS_ENV}_#{options[:prefix]}_#{options[:suffix]}_schema.rb"
	end

end
