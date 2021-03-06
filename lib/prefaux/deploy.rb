require_relative "output"
require "yaml"

module Prefaux
  class Deploy < Output
    def to_h
      @deploy ||= stringify_keys({
        appname: opts.instance_name,
        deployer_env: opts.rails ? "rails.capfile" : "norails.capfile",
        deploy_dir: opts.target_deploy_path,
        rails_env: opts.rails_env,
        assets_prefix: opts.assets_prefix,
        systemd_services: [
          "#{opts.instance_name}.target"
        ]
      })
    end

    def keys
      [
        :instance_name,
        :rails,
        :target_deploy_path,
        :assets_prefix
      ]
    end

    def to_s
      YAML.dump(to_h)
    end
  end
end
