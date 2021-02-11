require 'spec_helper'
require 'rack/test'
include Rack::Test::Methods

describe Crono::Engine do
  let(:app) { Crono::Engine }

  before do
    Crono::CronoJob.destroy_all
    @test_job_id = 'Perform TestJob every 5 seconds'
    @test_job_log = 'All runs ok'
    @test_job = Crono::CronoJob.create!(
      job_id: @test_job_id,
      log: @test_job_log
    )
  end

  after { @test_job.destroy }

  describe '/' do
    it 'should show all jobs' do
      get '/'
      expect(last_response).to be_ok
      expect(last_response.body).to include @test_job_id
    end

    it 'should show a error mark when a job is unhealthy' do
      @test_job.update(healthy: false, last_performed_at: 10.minutes.ago)
      get '/'
      expect(last_response.body).to include 'Error'
    end

    it 'should show a success mark when a job is healthy' do
      @test_job.update(healthy: true, last_performed_at: 10.minutes.ago)
      get '/'
      expect(last_response.body).to include 'Success'
    end

    it 'should show a pending mark when a job is pending' do
      @test_job.update(healthy: nil)
      get '/'
      expect(last_response.body).to include 'Pending'
    end
  end

  describe '/job/:id' do
    it 'should show job log' do
      get "/jobs/#{@test_job.id}"
      expect(last_response).to be_ok
      expect(last_response.body).to include @test_job_id
      expect(last_response.body).to include @test_job_log
    end

    it 'should show a message about the unhealthy job' do
      message = 'An error occurs during the last execution of this job'
      @test_job.update(healthy: false)
      get "/jobs/#{@test_job.id}"
      expect(last_response.body).to include message
    end
  end
end
