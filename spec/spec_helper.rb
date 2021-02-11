require 'bundler/setup'
Bundler.setup

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)

require 'timecop'
require 'byebug'
require 'crono'
require 'generators/crono/install/templates/migrations/create_crono_jobs.rb'

# setting default time zone
# In Rails project, Time.zone_default equals "UTC"
Time.zone_default = Time.find_zone('UTC')

ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: 'file::memory:?cache=shared'
)

ActiveRecord::Base.logger = Logger.new($stdout)
CreateCronoJobs.up

class TestJob
  def perform
  end
end

class TestFailingJob
  def perform
    raise 'Some error'
  end
end
