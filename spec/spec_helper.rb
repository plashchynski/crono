require 'bundler/setup'
Bundler.setup

require 'timecop'
require 'byebug'
require 'crono'
require 'generators/crono/install/templates/migrations/create_crono_jobs.rb'

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'file::memory:?cache=shared'
)

ActiveRecord::Base.logger = Logger.new(STDOUT)
CreateCronoJobs.up
