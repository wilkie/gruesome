require 'optparse'

require_relative '../gruesome'
require_relative 'machine'
require_relative 'logo'

module Gruesome
  class CLI
    BANNER = <<-USAGE
    Usage:
      gruesome play STORY_FILE

    Description:
      The 'play' command will start a session of the story given as STORY_FILE

    Example:
      gruesome play zork1.z3

    USAGE

    class << self
      def parse_options
        @opts = OptionParser.new do |opts|
          opts.banner = BANNER.gsub(/^\t{2}/, '')

          opts.separator ''
          opts.separator 'Options:'

          opts.on('-h', '--help', 'Display this help') do
            puts opts
            exit
          end
        end

        @opts.parse!
      end

      def CLI.run
        begin
          parse_options
        rescue OptionParser::InvalidOption => e
          warn e
          exit -1
        end

        def fail
          puts @opts
          exit -1
        end

        if ARGV.empty?
          fail
        end

        case ARGV.first
        when 'play'
          fail unless ARGV[1]

          Gruesome::Logo.print

          puts
          puts "--------------------------------------------------------------------------------"
          puts

          Gruesome::Machine.new(ARGV[1]).execute
        end
      end
    end
  end
end
