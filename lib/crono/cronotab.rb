module Crono
  class Cronotab
    def self.process(cronotab_path = nil)
      cronotab_path ||= ENV['CRONOTAB'] || (defined?(Rails) &&
                        File.join(Rails.root, Config::CRONOTAB))
      fail 'No cronotab defined' unless cronotab_path
      require cronotab_path
    end
  end
end
