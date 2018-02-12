require_relative "../lib/options"
require_relative "../lib/deploy"
require_relative "../lib/infrastructure"
require_relative "../lib/instance"
require_relative "../lib/inventory"
require "fileutils"

class RunCommand
  def initialize(arg_list)
    @arg_list = arg_list
  end

  def execute
    write(
      "#{options.output_dir}/faux-deploy/deploy.yml",
      Deploy.new(options).validate!
    )
    write(
      "#{options.output_dir}/faux-infrastructure/infrastructure.yml",
      Infrastructure.new(options).validate!
    )
    write(
      "#{options.output_dir}/fauxpaas/data/instances/#{name}/instance.yml",
      Instance.new(options).validate!
    )
    write(
      "#{options.output_dir}/fauxpaas/data/instances/#{name}/hosts.rb",
      Inventory.new(options).validate!
    )

    FileUtils.mkdir_p "#{options.output_dir}/fauxpaas/data/stages"
    Dir.chdir("#{options.output_dir}/fauxpaas/data/stages") do
      FileUtils.ln_s("../instances/#{name}/hosts.rb", "#{name}.rb")
    end
  end

  private
  attr_reader :arg_list

  def options
    @options ||= Options.new.parse(arg_list)
  end

  def name
    options.instance_name
  end

  def write(path, payload)
    path = Pathname.new(path)
    FileUtils.mkdir_p path.dirname
    File.write(path, payload.to_s)
  end

end
