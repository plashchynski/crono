require 'spec_helper'
require 'rake'

load 'tasks/crono_tasks.rake'
Rake::Task.define_task(:environment)

describe 'crono:clean' do
  it 'should clean unused tasks from DB' do
    Crono::CronoJob.create!(job_id: 'used_job')
    expect(Crono).to receive(:load_cronotab)
    Rake::Task['crono:clean'].invoke
    expect(Crono::CronoJob.where(job_id: 'used_job')).not_to exist
  end
end
