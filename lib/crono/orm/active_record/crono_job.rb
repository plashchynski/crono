require 'active_record'

module Crono
  class CronoJob < ActiveRecord::Base
    self.table_name = "crono_jobs"
    validates :job_id, presence: true, uniqueness: true
  end
end
