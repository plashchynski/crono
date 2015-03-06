require 'bundler/setup'
Bundler.setup

require 'timecop'
require 'crono'
require 'generators/crono/install/templates/migrations/create_crono_jobs.rb'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)
CreateActiveAdminComments.up

RSpec.configure do |config|
end
