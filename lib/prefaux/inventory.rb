require_relative "output"

module Prefaux
  class Inventory < Output
    def to_s
      @inventory ||= opts.hosts.map do |host|
        "server '#{host}', roles: [:app]"
      end.join("\n").concat("\n")
    end

    def keys
      [:hosts]
    end
  end

end
