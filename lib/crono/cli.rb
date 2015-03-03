require 'crono'

module Crono
  class CLI
    include Singleton

    def run
      load_rails
      print_banner
    end

    def print_banner
      puts "Loading Crono #{Crono::VERSION}"
      puts "Running in #{RUBY_DESCRIPTION}"
    end

    def load_rails
      require 'rails'
      require File.expand_path("config/environment.rb")
      ::Rails.application.eager_load!
    end
  end
end
