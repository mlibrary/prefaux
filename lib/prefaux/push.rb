require "tmpdir"
require "open3"

module Prefaux
  class PushCheck
    def run
      _, _, status = Open3.capture3("ssh -T git@github.com")
      if status.exitstatus == 255
        raise RuntimeError, "Could not connect to github over ssh. Are your credentials loaded?"
      end
    end
  end

  class FullPush
    def initialize(dir, repo, branch)
      @dir = dir
      @repo = repo
      @branch = branch
    end

    def run
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          system("git clone -q --depth 1 #{repo} .")
          system("git checkout -q -b #{branch}")
          system("cp -R #{dir}/* .")
          system("git add .")
          system("git commit -q -m 'prefaux pushed'")
          system("git push -q -u origin #{branch}")
        end
      end
      true
    end

    private

    attr_reader :dir, :repo, :branch
  end

  class EmptyPush
    def initialize(repo, branch)
      @repo = repo
      @branch = branch
    end

    def run
      Dir.mktmpdir do |tmpdir|
        Dir.chdir(tmpdir) do
          system("git clone -q --depth 1 #{repo} .")
          system("git checkout -q -b #{branch}")
          system("git push -q -u origin #{branch}")
        end
      end
      true
    end

    private

    attr_reader :repo, :branch
  end

  class RsyncPush
    def initialize(source, dest)
      @source = source
      @dest = dest
    end

    def run
      system("rsync --chmod=Dg+rs,g+rw --no-perms --recursive --links --quiet #{source}/* #{dest}/")
    end

    private
    attr_reader :source, :dest
  end

end
