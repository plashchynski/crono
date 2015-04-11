require 'bundler/setup'
Bundler.setup

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

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

class TestJob
  def perform
  end
end

class TestFailingJob
  def perform
    fail 'Some error'
  end
end
