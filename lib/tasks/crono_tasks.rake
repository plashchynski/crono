module Crono
  def self.load_cronotab
    cronotab_path = ENV['CRONOTAB'] || (defined?(Rails) &&
                      File.join(Rails.root, cronotab_path))
    fail 'No cronotab defined' unless cronotab_path
    puts "Load cronotab #{cronotab_path}"
    require cronotab_path
  end
end

namespace :crono do
  desc 'Clean unused job stats from DB'
  task clean: :environment do
    Crono.scheduler = Crono::Scheduler.new
    Crono.load_cronotab
    current_job_ids = Crono.scheduler.jobs.map(&:job_id)
    Crono::CronoJob.where.not(job_id: current_job_ids).destroy_all
  end

  desc 'Check cronotab.rb syntax'
  task check: :environment do
    Crono.scheduler = Crono::Scheduler.new
    Crono.load_cronotab
    puts 'Syntax ok'
  end
end
