module Crono
  # Crono::CronoJob is a ActiveRecord model to store job state
  class CronoJob < ActiveRecord::Base
    self.table_name = 'crono_jobs'
    validates :job_id, presence: true, uniqueness: true

    def self.outdated
      self
    end
  end
end
