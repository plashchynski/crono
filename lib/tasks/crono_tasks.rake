namespace :crono do
  desc 'Clean unused job stats from DB'
  task clean: :environment do
    Crono.scheduler = Crono::Scheduler.new
    require File.join(Rails.root, 'config', 'cronotab')
    current_job_ids = Crono.scheduler.jobs.map(&:job_id)
    Crono::CronoJob.where.not(job_id: current_job_ids).destroy_all
  end
end
