# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.10' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

	config.plugin_paths = [
		File.expand_path(File.join(File.dirname(__FILE__),'../..'))
	]
	config.plugins = [:use_db]

	if RUBY_PLATFORM =~ /java/
#
#	Testing had 
#		SystemStackError: stack level too deep
#    /test/unit/gamma_test.rb:13:in `test_should_create'
#
#	I couldn't resolve, so tried an updated adapter and it worked.
#	Perhaps the problems that I had with 1.0.1 have been resolved.
#
		#	For functionality with rvm/jruby
		#	I expected to have to change database.yml for this but didn't
		config.gem 'activerecord-jdbcsqlite3-adapter',
			:lib => 'active_record/connection_adapters/jdbcsqlite3_adapter'	#,
#			:version => '~>0.9'
		#	1.0.1 is for rails 3 I think
		config.gem 'activerecord-jdbcmysql-adapter',
			:lib => 'active_record/connection_adapters/jdbcmysql_adapter'	#,
#			:version => '~>0.9'
		#	1.0.1 is for rails 3 I think

		config.gem 'jdbc-mysql', :lib => 'jdbc/mysql'
		#	Additional jruby specific jars required in the war
		config.gem 'jdbc-sqlite3', :lib => 'jdbc/sqlite3'
		config.gem 'jruby-openssl', :lib => 'openssl'
	else

		# If using mysql ...
		# On Mac OS X:
		#   sudo gem install mysql -- --with-mysql-dir=/usr/local/mysql
		# On Mac OS X Leopard:
		#   sudo env ARCHFLAGS="-arch i386" gem install mysql 
		#			-- --with-mysql-config=/usr/local/mysql/bin/mysql_config
		# ... however, I had to install the mysql gem like so ...
		#   sudo env ARCHFLAGS="-arch x86_64" gem install mysql 
		#			-- --with-mysql-config=/usr/local/mysql/bin/mysql_config

		config.gem 'mysql'
		config.gem "sqlite3-ruby", :lib => "sqlite3"
	end
	config.gem "jakewendt-simply_testable", :lib => "simply_testable"

	config.time_zone = 'UTC'
end
