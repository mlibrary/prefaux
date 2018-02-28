require "ostruct"
require "optparse"

class Options < OpenStruct
  def initialize
    super({
      rails_env: "production",
      redis: [],
      default_branch: "master",
      assets_prefix: "assets",
    })
  end

  def parse(args)
    parser.parse!(args.empty? ? ["--help"] : args)
    self.instance_name = self.puma_svc_app_name
    self.output_dir ||= File.join(Dir.pwd, "#{self.instance_name}-out")
    self
  end
  alias_method :parse!, :parse

  private

  def parser
    @parser = OptionParser.new do |opts|
      opts.banner =  "" \
        "This is meant to be run after predeploy, and before fauxpaas.\n" \
        "It generates the artifacts needed by fauxpaas from those created\n" \
        "by predeploy.\n" \
        "Usage:\n" \
        "#{File.basename(__FILE__)} [options]"
      opts.separator ""
      opts.separator "Specific options:"

      opts.on("-r", "--[no-]rails", "Whether or not this is a rails app.") do |r|
        self.rails = r
      end

      opts.on("-e", "--rails-env ENV", "The rails env #{default(:rails_env)}") do |env|
        self.rails_env = env
      end

      opts.on("--redis 1,2,3", Array, "A list of redis 0 or more redis servers") do |r|
        self.redis = [r].flatten
      end

      opts.on("--hosts x,y,z", Array, "A list of hosts to which we deploy") do |h|
        self.hosts = [h].flatten
      end

      opts.on("-s", "--source SOURCE_REPO", "The source code repository") do |s|
        self.source = s
      end

      opts.on("-b", "--default-branch BRANCH", "The default branch of the source to deploy",
              " #{default(:default_branch)}") do |b|
                self.default_branch = b
      end

      opts.on("-a", "--assets-prefix PREFIX", "The assets prefix #{default(:assets_prefix)}") do |a|
        self.assets_prefix = a
      end

      opts.on("-f", "--prevars PATH", "The path to the variables file created for ansible") do |f|
        YAML.load(File.read(f)).each_pair do |k,v|
          self.send(:"#{k}=", v)
        end
      end

      opts.on("-o", "--output PATH", "Path where output should be written. Optional.") do |o|
        self.output_dir = o
      end

      opts.on("-h", "--help", "Print this help") do
        puts opts
        exit
      end
    end
  end

  def default(field)
    if send(field) != :missing
      "(default: #{self.send(field)})"
    else
      ""
    end
  end

end


