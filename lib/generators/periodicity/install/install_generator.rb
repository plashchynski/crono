module Periodicity
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Installs periodicity and generates the necessary configuration files"
      source_root File.expand_path("../templates", __FILE__)

      def copy_config
        template 'periodicity.rb.erb', 'config/initializers/periodicity.rb'
      end
    end
  end
end
