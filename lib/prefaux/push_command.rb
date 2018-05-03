require_relative "config"
require_relative "push"
require_relative "permitter"
require "fileutils"

module Prefaux
  class PushCommand
    def initialize(options)
      @options = options
    end

    def execute
      PushCheck.new.run
      ["deploy", "infrastructure"].each do |aspect|
        repo = "git@github.com:mlibrary/faux-#{aspect}.git"
        subdir = (dir/"faux-#{aspect}").expand_path
        puts "Pushing #{subdir} to #{repo} #{instance_name}"
        FullPush.new(subdir, repo, instance_name).run
      end
      push_dev
      push_instance
      permit_source
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

    def permit_source
      if options.source.match?(/github.com[:\/]/i)
        puts "Permitting fauxpaas to read from Github source"
        Permitter.new(options.source).execute
      end
    end
  end

end
