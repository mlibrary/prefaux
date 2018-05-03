require_relative "output"
require "yaml"

module Prefaux
  class Permissions < Output
    def to_h
      {
        "admin" => [opts.tech_lead],
        "edit" => [],
        "deploy" => opts.user_deploy_users,
        "read" => [],
        "restart" => []
      }
    end

    def keys
      [
        :tech_lead,
        :user_deploy_users
      ]
    end

    def to_s
      YAML.dump(to_h)
    end
  end

end
