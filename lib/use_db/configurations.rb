module Configurations
	def self.included(base)
		unless base.methods.include?(:configurations_with_other_dbs)
			base.extend(ClassMethods)
			base.class_eval do
				class << self
					alias_method_chain :configurations, :other_dbs
				end
			end
		end
	end
	module ClassMethods
		def configurations_with_other_dbs
#			puts "In configurations with other dbs"
			if configurations_without_other_dbs.empty?
				#	for rake tasks
				configurations_without_other_dbs.update(YAML::load(ERB.new(IO.read(
					File.join( Rails.root,'config','database.yml'))).result))
			end
			OTHER_DB_FILES.each do |f|
				configurations_without_other_dbs.update(YAML::load(ERB.new(IO.read(f)).result))
			end if defined?(OTHER_DB_FILES)
			configurations_without_other_dbs
		end
	end
end
ActiveRecord::Base.send(:include,Configurations)
