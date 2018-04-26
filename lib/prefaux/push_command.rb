require_relative "push_options"
require_relative "push"
require "fileutils"

module Prefaux
  class PushCommand
    def initialize(arg_list)
      @options = PushOptions.new.parse(arg_list)
    end

    def execute
      ["deploy", "infrastructure"].each do |aspect|
        repo = "git@github.com:mlibrary/faux-#{aspect}.git"
        subdir = (dir/"faux-#{aspect}").expand_path
        puts "Pushing #{subdir} to #{repo} #{instance_name}"
        FullPush.new(subdir, repo, instance_name).run
      end
      push_dev
      push_instance
    end

    private
    attr_reader :options

    def dir
      Pathname.new(options.dir)
    end

    def instance_name
      (dir/"fauxpaas"/"data"/"instances")
        .children
        .first
        .basename
    end

    def push_dev
      repo = "git@github.com:mlibrary/faux-dev.git"
      puts "Creating branch #{repo} #{instance_name}"
      EmptyPush.new(repo, instance_name).run
    end

    def push_instance
      puts "Pushing instance to #{options.instance_dest}"
      RsyncPush.new(dir/"fauxpaas", options.instance_dest).run
    end
  end

end
