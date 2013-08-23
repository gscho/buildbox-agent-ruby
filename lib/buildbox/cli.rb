require 'optparse'

module Buildbox
  class CLI
    attr_reader :argv

    def initialize(argv)
      @argv     = argv
      @commands = {}
      @options  = {}

      @commands['server:start'] = OptionParser.new do |opts|
        opts.banner = "Usage: buildbox server:start"

        opts.on("--help", "You're looking at it.") do
          puts @commands['server:start']
          exit
        end
      end

      @commands['version'] = OptionParser.new do |opts|
        opts.banner = "Usage: buildbox version"
      end
    end

    def parse
      global.order!

      if command
        if @commands.has_key?(command)
          @commands[command].parse!
        else
          puts "`#{command}` is an unknown command"
          exit 1
        end

        if command == "version"
          puts Buildbox::VERSION
          exit
        end

        if command == "server:start"
          Buildbox::Server.new.start
        elsif command == "add"
          # Buildbox.config.update(:worker_access_tokens=> [ "5f6e1a888c8ef547f6b3" ])
        end
      else
        puts global.help
      end
    end

    private

    def command
      @command ||= @argv.shift
    end

    def global
      @global ||= OptionParser.new do |opts|
        opts.version = Buildbox::VERSION
        opts.banner  = 'Usage: buildbox COMMAND [command-specific-actions]'

        opts.separator help
      end
    end

    def help
<<HELP

  worker   #  add a worker (add)
  server   #  start the buildbox build server (start)
  version  #  display version

HELP
    end
  end
end
