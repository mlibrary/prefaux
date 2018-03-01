require "yaml"
require "pathname"
require_relative "../lib/prefaux/files_command"
require "fakefs/spec_helpers"

RSpec.describe Prefaux::FilesCommand do
  include FakeFS::SpecHelpers

  let(:fixture_path) { File.join(File.dirname(__FILE__), "fixtures") }
  let(:prevars_path) { File.join(fixture_path, "fake.testing.ansible_vars.yml") }
  let(:outpath) { Pathname.new(__FILE__).parent+"fake-testing-out" }
  let(:args) do
    "--rails" \
      " --rails-env rails_testing" \
      " --redis 1.redis.com,2.redis.com" \
      " --hosts yuengling,goatmilk-1,chianti" \
      " --source https://github.com/mlibrary/closet.git" \
      " -f #{prevars_path}" \
      " -o #{outpath}"
  end
  let(:cmd) { described_class.new(args.split) }

  before(:each) do
    FakeFS::FileSystem.clone(prevars_path)
    cmd.execute
  end

  describe "deploy.yml" do
    let(:path) { outpath+"faux-deploy"+"deploy.yml" }
    let(:subject) { YAML.load(File.read(path)) }

    it { expect(subject["appname"]).to eql("fake-testing") }
    it { expect(subject["deployer_env"]).to eql("rails.capfile") }
    it { expect(subject["deploy_dir"]).to eql("/some/path/fake-testing") }
    it { expect(subject["rails_env"]).to eql("rails_testing") }
    it { expect(subject["assets_prefix"]).to eql("assets") }
    it "sets systemd_services" do
      expect(subject["systemd_services"]).to contain_exactly(
        "app-puma@fake-testing.service"
      )
    end
  end

  describe "infrastructure.yml" do
    let(:path) { outpath+"faux-infrastructure"+"infrastructure.yml" }
    let(:subject) { YAML.load(File.read(path)) }

    it { expect(subject["base_dir"]).to eql("/some/path/fake-testing") }
    it { expect(subject["bind"]).to eql("127.0.0.1:30060") }
    it "sets redis" do
      expect(subject["redis"]).to eql(
        "1" => "1.redis.com",
        "2" => "2.redis.com"
      )
    end
    it { expect(subject["db"]["adapter"]).to eql("mysql2") }
    it { expect(subject["db"]["username"]).to eql("fk-tstng") }
    it "sets db.password" do
      expect(subject["db"]["password"]).to eql(
        "sd0f98as0f8a08as0df8a0sdfa0sd8f0a8df0asf"
      )
    end
    it { expect(subject["db"]["host"]).to eql("db-fake-testing") }
    it { expect(subject["db"]["port"]).to eql(3306) }
    it { expect(subject["db"]["database"]).to eql("fake-testing") }
    it "sets the url" do
      expect(subject["db"]["url"]).to eql(
        "mysql2://fk-tstng:" \
        "sd0f98as0f8a08as0df8a0sdfa0sd8f0a8df0asf@" \
        "db-fake-testing:3306/fake-testing"
      )
    end
  end

  describe "instance.yml" do
    let(:path) { outpath+"fauxpaas"+"data"+"instances"+"fake-testing"+"instance.yml" }
    let(:subject) { YAML.load(File.read(path)) }
    it "sets source.url" do
      expect(subject["source"]["url"]).to eql(
        "https://github.com/mlibrary/closet.git"
      )
    end
    it "sets source" do
      expect(subject["source"]).to eql({
        "url" => "https://github.com/mlibrary/closet.git",
        "commitish" => "master"
      })
    end
    it "sets deploy" do
      expect(subject["deploy"]).to eql({
        "url" => "https://github.com/mlibrary/faux-deploy.git",
        "commitish" => "fake-testing"
      })
    end
    it "sets shared" do
      expect(subject["shared"]).to contain_exactly({
        "url" => "https://github.com/mlibrary/faux-infrastructure.git",
        "commitish" => "fake-testing"
      })
    end
    it "sets unshared" do
      expect(subject["unshared"]).to contain_exactly({
        "url" => "https://github.com/mlibrary/faux-dev.git",
        "commitish" => "fake-testing"
      })
    end
  end

  describe "hosts.rb" do
    let(:path) { outpath+"fauxpaas"+"data"+"instances"+"fake-testing"+"hosts.rb" }
    let(:subject) { File.read(path) }
    it "lists the servers" do
      expect(subject.split("\n")).to contain_exactly(
        "server 'yuengling', roles: [:app]",
        "server 'goatmilk-1', roles: [:app]",
        "server 'chianti', roles: [:app]"
      )
    end
  end

  describe "stages/fake-testing.rb" do
    let(:path) { outpath+"fauxpaas"+"data"+"stages"+"fake-testing.rb" }
    let(:subject) { File.read(path) }
    it "is a symlink" do
      expect(File.symlink?(path)).to be true
    end
    it "lists the servers" do
      expect(subject.split("\n")).to contain_exactly(
        "server 'yuengling', roles: [:app]",
        "server 'goatmilk-1', roles: [:app]",
        "server 'chianti', roles: [:app]"
      )
    end
  end


end
