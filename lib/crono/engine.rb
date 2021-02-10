module Crono
  class Engine < ::Rails::Engine
    isolate_namespace Crono

    initializer 'crono.assets.precompile' do |app|
      app.config.assets.precompile += %w( crono/application.css crono/materialize.min.css )
    end
  end
end
