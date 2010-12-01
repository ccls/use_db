namespace :db do
	namespace :structure do
		task :dump_use_db do						
			UseDbTest.other_databases.each do |options| 
				puts "DUMPING TEST DB: #{options.inspect}" if UseDbPlugin.debug_print
				UseDbTest.dump_db_structure(options)
			end
		end
	end
	
	namespace :test do
		task :clone_structure => "db:test:clone_structure_use_db"

		task :clone_structure_use_db => ["db:structure:dump_use_db","db:test:purge_use_db"] do
			UseDbTest.other_databases.each do |options|	 
				puts "CLONING TEST DB: #{options.inspect}" if UseDbPlugin.debug_print
				UseDbTest.clone_db_structure(options)
			end
		end
		
		task :purge_use_db => "db:test:purge" do
			UseDbTest.other_databases.each do |options|
				puts "PURGING TEST DB: #{options.inspect}" if UseDbPlugin.debug_print
				UseDbTest.purge_db(options)
			end
		end	
	end
end

require 'use_db'
Rake::Task[:rails_env].prerequisites.unshift(:environment )

namespace :test do
	task :units => "db:test:clone_structure_use_db"
	task :functionals => "db:test:clone_structure_use_db"
	task :integrations => "db:test:clone_structure_use_db"
end
