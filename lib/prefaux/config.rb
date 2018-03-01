module Prefaux
  class << self
    attr_reader :settings
    attr_writer :env

    def root
      @root ||= Pathname.new(__FILE__).dirname.parent
    end

    def env
      @env ||= ENV["FAUXPAAS_ENV"] || ENV["RAILS_ENV"] || "development"
    end

    def load_settings!(hash = {})
      @settings = Ettin.for(Ettin.settings_files(root/"config", env))
      @settings.merge!(hash)
    end

  end
end
