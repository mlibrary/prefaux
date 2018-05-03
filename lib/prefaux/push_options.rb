require "ostruct"
require "optparse"
require "pathname"
require_relative "config"

module Prefaux
  class PushOptions < OpenStruct
    def initialize
      super(Prefaux.settings.to_h)
    end

    def parse(args)
      parser.parse!(args.empty? ? ["--help"] : args)
      self
    end
    alias_method :parse!, :parse

    private

    def parser
      @parser = OptionParser.new do |opts|
        opts.banner =  "" \
          "Creates Github branches for fauxpaas from the artifacts created\n" \
          "by bin/prefaux.\n" \
          "Usage: push -d dir/to/push -s source_url [options]"
        opts.separator ""
        opts.separator "Specific options:"

        opts.on("-d", "--dir PATH", "The top-level dir to push, e.g fulcrum-testing-out") do |d|
          self.dir = Pathname.new(d)
        end

        opts.on("-s", "--source SOURCE_REPO", "The source code repository") do |s|
          self.source = s
        end

        opts.on("-h", "--help", "Print this help") do
          puts opts
          exit
        end
      end
    end

  end



end
