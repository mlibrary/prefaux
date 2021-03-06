require "json"

module Prefaux
  class Output
    def initialize(opts)
      @opts = opts
    end

    def to_s
      raise NotImplementedError
    end

    def keys
      []
    end

    def missing
      keys.select{|k| opts.send(k).nil? }
    end

    def valid?
      missing.empty?
    end

    def validate!
      unless valid?
        raise KeyError, "Missing keys:\n\t#{missing.join(" :")}"
      end
      self
    end

    def stringify_keys(hash)
      JSON.parse(JSON.dump(hash))
    end

    private
    attr_reader :opts
  end

end
