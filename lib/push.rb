require "tmpdir"

class Push
  def initialize(dir, repo, branch)
    @dir = dir
    @repo = repo
    @branch = branch
  end

  def run
    Dir.mktmpdir do |tmpdir|
      Dir.chdir(tmpdir) do
        `git clone --depth 1 #{repo} .`
        `git checkout -b #{branch}`
        `cp -R #{dir}/* .`
        require "pry"; binding.pry
        `git add .`
        binding.pry
        `git commit -m "prefaux pushed"`
        `git push -u origin #{branch}`
      end
    end
    true
  end

  private

  attr_reader :dir, :repo, :branch
end
