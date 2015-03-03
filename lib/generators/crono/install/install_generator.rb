module Crono
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      desc "Installs crono and generates the necessary configuration files"
      source_root File.expand_path("../templates", __FILE__)

      def copy_config
        template 'cronotab.rb.erb', 'config/cronotab.rb'
      end
    end
  end
end
