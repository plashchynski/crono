namespace :crono do
  desc 'Clean unused job stats from DB'
  task clean: :environment do
    Crono.scheduler = Crono::Scheduler.new
    Crono::Cronotab.process
    current_job_ids = Crono.scheduler.jobs.map(&:job_id)
    Crono::CronoJob.where.not(job_id: current_job_ids).destroy_all
  end

  desc 'Check cronotab.rb syntax'
  task check: :environment do
    Crono.scheduler = Crono::Scheduler.new
    Crono::Cronotab.process
    puts 'Syntax ok'
  end
end
