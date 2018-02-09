require_relative "../lib/push"
require "optparse"
require "pathname"

dir = nil
OptionParser.new do |opts|
  opts.banner = "Usage: push.rb -d dir/to/push"

  opts.on("-d", "--dir PATH", "The top-level dir to push, e.g fulcrum-testing-out") do |d|
    dir = Pathname.new(d)
  end
end.parse!

raise ArgumentError, "--dir is required" unless dir

instance_name = (dir/"fauxpaas"/"data"/"instances").children.first.basename

["deploy", "infrastructure"].each do |aspect|
  repo = "git@github.com:mlibrary/faux-#{aspect}.git"
  subdir = (dir/"faux-#{aspect}").expand_path
  puts "Pushing #{subdir} to #{repo} #{instance_name}"
  Push.new(subdir, repo, instance_name).run
end
