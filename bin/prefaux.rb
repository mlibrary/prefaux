require_relative "../lib/options"
require_relative "../lib/deploy"
require_relative "../lib/infrastructure"
require_relative "../lib/instance"
require_relative "../lib/inventory"

options = Options.new.parse
name = options.instance_name

# Write deploy.yml
`mkdir -p #{options.output_dir}/faux-deploy/`
File.write(
  "#{options.output_dir}/faux-deploy/deploy.yml",
  Deploy.new(options).validate!.to_s
)

# Write infrastructure.yml
`mkdir -p #{options.output_dir}/faux-infrastructure/`
File.write(
  "#{options.output_dir}/faux-infrastructure/infrastructure.yml",
  Infrastructure.new(options).validate!.to_s
)

# Write instance.yml
`mkdir -p #{options.output_dir}/fauxpaas/data/instances/#{name}`
File.write(
  "#{options.output_dir}/fauxpaas/data/instances/#{name}/instance.yml",
  Instance.new(options).validate!.to_s
)

# Write inventory and symlink stage
`mkdir -p #{options.output_dir}/fauxpaas/data/instances`
File.write(
  "#{options.output_dir}/fauxpaas/data/instances/#{name}/hosts.rb",
  Inventory.new(options).validate!.to_s
)
`mkdir -p #{options.output_dir}/fauxpaas/data/stages`
Dir.chdir("#{options.output_dir}/fauxpaas/data/stages") do
  `ln -s ../instances/#{name}/hosts.rb #{name}.rb`
end

