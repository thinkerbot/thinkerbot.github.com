require 'thinkerbot/version'

module Thinkerbot
  class Project
    class << self
      def normalize(config, default={})
        if config.kind_of?(String)
          config = {'url' => config}
        end

        default.merge(config)
      end
    end

    include Utils

    attr_reader :config
    attr_reader :logger

    def initialize(config, logger)
      @config = config
      @logger = logger
    end

    def url
      config['url'] or raise "no url specified: #{config.inspect}"
    end

    def name
      config['name'] ||= File.basename(url).chomp(File.extname(url))
    end

    def default_version_config
      { 
        'name'   => name,
        'rdoc'   => config['rdoc'],
        'rcov'   => config['rcov'],
        'ruby'   => config['ruby'],
        'rubies' => config['rubies']
      }
    end

    def versions
      config['versions'] ||= begin
        list = log_sh "gem list -a --remote #{name}"
        list =~ /^#{name} \((.*)\)$/
        $1.to_s.split(', ')
      end
    end

    def releases
      @releases ||= begin
        versions.map do |config|
          config = Version.normalize(config, default_version_config)
          Version.new(config, logger)
        end
      end
    end
  end
end