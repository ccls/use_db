# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.11' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|

#	config.plugin_paths = [
#		File.expand_path(File.join(File.dirname(__FILE__),'../..'))
#	]
#	config.plugins = [:use_db]

	if RUBY_PLATFORM =~ /java/
		config.gem 'activerecord-jdbcsqlite3-adapter',
			:lib => 'active_record/connection_adapters/jdbcsqlite3_adapter'
		config.gem 'activerecord-jdbcmysql-adapter',
			:lib => 'active_record/connection_adapters/jdbcmysql_adapter'
		config.gem 'jdbc-mysql', :lib => 'jdbc/mysql'
		config.gem 'jdbc-sqlite3', :lib => 'jdbc/sqlite3'
	else
		config.gem 'mysql'
		config.gem "sqlite3-ruby", :lib => "sqlite3"
	end
	config.gem "jakewendt-rails_extension"
	config.gem "jakewendt-html_test"

	config.time_zone = 'UTC'

	OTHER_DB_FILES =[
		File.join( Rails.root,'config','beta_database.yml'),
		File.join( Rails.root,'config','gamma_database.yml')
	]
	USE_DB_CONFIG = "#{RAILS_ROOT}/config/my_use_db.yml"

	config.after_initialize do
		require 'use_db'
		require 'alpha'
		require 'beta'
		require 'gamma'
		require 'normal'
	end
end
