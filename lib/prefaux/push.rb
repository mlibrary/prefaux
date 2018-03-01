require "tmpdir"

module Prefaux
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

end
