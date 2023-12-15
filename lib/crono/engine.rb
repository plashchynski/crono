module Crono
  class Engine < ::Rails::Engine
    isolate_namespace Crono

    initializer 'crono.assets.precompile' do |app|
      if app.config.respond_to?(:assets)
        app.config.assets.precompile += %w( crono/application.css crono/materialize.min.css )
      else
        fail "Crono requires either Propshaft or Sprockets to be installed."
      end
    end

    config.generators do |g|
      g.test_framework :rspec
      g.assets false
      g.helper false
    end
  end
end
