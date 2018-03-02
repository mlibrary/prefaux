require_relative "output"
require "yaml"

module Prefaux
  class Instance < Output
    def to_h
      @instance ||= stringify_keys({
        deploy: {
          url: "git@github.com:mlibrary/faux-deploy.git",
          commitish: opts.instance_name
        },
        source: {
          url: opts.source,
          commitish: opts.default_branch
        },
        shared: [
          {
            url: "git@github.com:mlibrary/faux-infrastructure.git",
            commitish: opts.instance_name
          }
        ],
        unshared: [
          {
            url: "git@github.com:mlibrary/faux-dev.git",
            commitish: opts.instance_name
          }
        ]
      })
    end

    def keys
      [
        :instance_name,
        :source,
        :default_branch
      ]
    end

    def to_s
      YAML.dump(to_h)
    end
  end

end
