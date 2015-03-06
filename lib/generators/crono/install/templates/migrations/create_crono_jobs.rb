class CreateActiveAdminComments < ActiveRecord::Migration
  def self.up
    create_table :crono_jobs do |t|
      t.string    :job_id, null: false
      t.text      :log
      t.datetime  :last_performed_at
      t.timestamps
    end
    add_index :crono_jobs, [:job_id]
  end

  def self.down
    drop_table :crono_jobs
  end
end
