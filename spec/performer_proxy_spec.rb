require 'spec_helper'

describe Crono::PerformerProxy do
  it 'should add job to schedule' do
    expect(Crono.scheduler).to receive(:add_job).with(kind_of(Crono::Job))
    Crono.perform(TestJob).every(2.days, at: '15:30')
  end
end
