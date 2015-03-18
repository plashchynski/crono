require 'spec_helper'
require 'rake'

load 'tasks/crono_tasks.rake'
Rake::Task.define_task(:environment)

describe 'rake' do
  describe 'crono:clean' do
    it 'should clean unused tasks from DB' do
      Crono::CronoJob.create!(job_id: 'used_job')
      ENV['CRONOTAB'] = File.expand_path('../../assets/good_cronotab.rb', __FILE__)
      Rake::Task['crono:clean'].invoke
      expect(Crono::CronoJob.where(job_id: 'used_job')).not_to exist
    end
  end

  describe 'crono:check' do
    it 'should check cronotab syntax' do
      ENV['CRONOTAB'] = File.expand_path('../../assets/bad_cronotab.rb', __FILE__)
      expect { Rake::Task['crono:check'].invoke }.to raise_error
    end
  end
end
