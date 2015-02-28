module Periodicity
  def self.hook_rails!
    ActiveSupport.on_load(:active_job) do
      extend Sidekiq::Extensions::ActiveJob
    end
  end

  class Rails < ::Rails::Engine
    initializer 'periodicity' do
      Periodicity.hook_rails!
    end
  end if defined?(::Rails)
end
