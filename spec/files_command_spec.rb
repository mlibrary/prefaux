require "yaml"
require "pathname"
require_relative "../lib/prefaux/options"
require_relative "../lib/prefaux/files_command"
require "pp"
require "fakefs/spec_helpers"

RSpec.describe Prefaux::FilesCommand do
  include FakeFS::SpecHelpers

  let(:fixture_path) { File.join(File.dirname(__FILE__), "fixtures") }
  let(:prevars_path) { File.join(fixture_path, "fake.testing.ansible_vars.yml") }
  let(:outpath) { Pathname.new(__FILE__).parent+"fake-testing-out" }
  let(:args) do
    "--rails" \
      " --tech-lead alice" \
      " --rails-env rails_testing" \
      " --redis 1.redis.com,2.redis.com" \
      " --hosts yuengling,goatmilk-1,chianti" \
      " --source git@github.com:mlibrary/closet.git" \
      " -f #{prevars_path}" \
      " -o #{outpath}"
  end
  let(:options) { Prefaux::Options.new.parse(args.split)  }
  let(:cmd) { described_class.new(options) }

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
        "fake-testing.target"
      )
    end
  end

  describe "infrastructure.yml" do
    let(:path) { outpath+"faux-infrastructure"+"infrastructure.yml" }
    let(:subject) { YAML.load(File.read(path)) }

    it { expect(subject["base_dir"]).to eql("/some/path/fake-testing") }
    it { expect(subject["relative_url_root"]).to eql("/some/relative/url/root") }
    it { expect(subject["bind"]).to eql("tcp://127.0.0.1:30060") }
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
    it "sets the db.url" do
      expect(subject["db"]["url"]).to eql(
        "mysql2://fk-tstng:" \
        "sd0f98as0f8a08as0df8a0sdfa0sd8f0a8df0asf@" \
        "db-fake-testing:3306/fake-testing"
      )
    end
    it "sets the solr.url" do
      expect(subject["solr"]["url"]).to eql("http://localhost:8082/solr/mycore")
    end
  end

  describe "instance.yml" do
    let(:path) { outpath+"fauxpaas"+"data"+"instances"+"fake-testing"+"instance.yml" }
    let(:subject) { YAML.load(File.read(path)) }
    it "sets source.url" do
      expect(subject["source"]["url"]).to eql(
        "git@github.com:mlibrary/closet.git"
      )
    end
    it "sets source" do
      expect(subject["source"]).to eql({
        "url" => "git@github.com:mlibrary/closet.git",
        "commitish" => "master"
      })
    end
    it "sets deploy" do
      expect(subject["deploy"]).to eql({
        "url" => "git@github.com:mlibrary/faux-deploy.git",
        "commitish" => "fake-testing"
      })
    end
    it "sets shared" do
      expect(subject["shared"]).to contain_exactly({
        "url" => "git@github.com:mlibrary/faux-infrastructure.git",
        "commitish" => "fake-testing"
      })
    end
    it "sets unshared" do
      expect(subject["unshared"]).to contain_exactly({
        "url" => "git@github.com:mlibrary/faux-dev.git",
        "commitish" => "fake-testing"
      })
    end
  end

  describe "permissions.yml" do
    let(:path) { outpath+"fauxpaas"+"data"+"instances"+"fake-testing"+"permissions.yml" }
    let(:subject) { YAML.load(File.read(path)) }
    it "writes the file" do
      expect(File.exist?(path)).to be true
    end
    it "sets read to []" do
      expect(subject["restart"]).to eql([])
    end
    it "sets restart to []" do
      expect(subject["restart"]).to eql([])
    end
    it "sets edit to []" do
      expect(subject["edit"]).to eql([])
    end
    it "sets deploy to user_deploy_users" do
      expect(subject["deploy"]).to contain_exactly("me", "you")
    end
    it "sets admin to [tech-lead]" do
      expect(subject["admin"]).to contain_exactly("alice")
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
