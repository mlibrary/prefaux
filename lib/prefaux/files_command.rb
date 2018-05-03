require_relative "deploy"
require_relative "infrastructure"
require_relative "instance"
require_relative "inventory"
require_relative "permissions"
require "fileutils"
require "pathname"

module Prefaux
  class FilesCommand
    def initialize(options)
      @options = options
    end

    def execute
      write(deploy_path,          deploy)
      write(infrastructure_path,  infrastructure)
      write(instance_path,        instance)
      write(inventory_path,       inventory)
      write(permissions_path,     permissions)
      write_stage
    end

    def deploy_path
      "#{options.output_dir}/faux-deploy/deploy.yml"
    end

    def deploy
      Deploy.new(options).validate!
    end

    def infrastructure_path
      "#{options.output_dir}/faux-infrastructure/infrastructure.yml"
    end

    def infrastructure
      Infrastructure.new(options).validate!
    end

    def instance_path
      "#{options.output_dir}/fauxpaas/data/instances/#{name}/instance.yml"
    end

    def instance
      Instance.new(options).validate!
    end

    def inventory_path
      "#{options.output_dir}/fauxpaas/data/instances/#{name}/hosts.rb"
    end

    def inventory
      Inventory.new(options).validate!
    end

    def permissions_path
      "#{options.output_dir}/fauxpaas/data/instances/#{name}/permissions.yml"
    end

    def permissions
      Permissions.new(options).validate!
    end

    private
    attr_reader :options

    def name
      options.instance_name
    end

    def write(path, payload)
      path = Pathname.new(path)
      FileUtils.mkdir_p path.dirname
      File.write(path, payload.to_s)
    end

    def write_stage
      FileUtils.mkdir_p "#{options.output_dir}/fauxpaas/data/stages"
      Dir.chdir("#{options.output_dir}/fauxpaas/data/stages") do
        FileUtils.ln_s("../instances/#{name}/hosts.rb", "#{name}.rb")
      end
    end
  end

end
