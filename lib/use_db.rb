require "use_db/use_db_plugin"
require "use_db/use_db_test"
require "use_db/test_model"
require 'active_record/fixtures'
require "use_db/override_fixtures"
require 'active_record/migration'
require 'use_db/override_test_case'
require "use_db/migration"

ActiveRecord::Base.extend(UseDbPlugin)
