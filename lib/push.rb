

puts "Pushing to faux-deploy"
Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    `git clone --depth 1 https://github.com/mlibrary/faux-deploy.git .`
    `git checkout -b #{name}`
    File.write("deploy.yml", YAML.dump(output.deploy))
    `git add deploy.yml`
    `git commit -m "prefaux adds deploy.yml for #{name}`
    `git push -u origin #{name}`
  end
end

puts ""
puts "Pushing to faux-infrastructure"
Dir.mktmpdir do |dir|
  Dir.chdir(dir) do
    `git clone --depth 1 https://github.com/mlibrary/faux-infrastructure.git .`
    `git checkout -b #{name}`
    File.write("infrastructure.yml", YAML.dump(output.infrastructure))
    `git add infrastructure.yml`
    `git commit -m "prefaux adds infrastructure.yml for #{name}`
    `git push -u origin #{name}`
  end
end

puts ""
puts "Completed successfully"


