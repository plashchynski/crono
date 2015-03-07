TMP_DB_FILE = "tmp/test_db.sqlite3"

require 'bundler/setup'
Bundler.setup

require 'timecop'
require 'byebug'
require 'crono'
require 'generators/crono/install/templates/migrations/create_crono_jobs.rb'

FileUtils.rm(TMP_DB_FILE) if File.exist?(TMP_DB_FILE)

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: TMP_DB_FILE)
ActiveRecord::Base.logger = Logger.new(STDOUT)
CreateCronoJobs.up

RSpec.configure do |config|
end
