require 'thinkerbot/release'

module Thinkerbot
  class Project
    class << self
      def normalize(config, default={})
        if config.kind_of?(String)
          config = {'url' => config}
        end

        unless url = config['url']
          raise "no url specified: #{config.inspect}"
        end

        {
          'name'   => default_name(url),
          'rdoc'   => default['rdoc'],
          'rcov'   => default['rcov'],
          'rubies' => default['rubies']
        }.merge(config)
      end

      def default_name(url)
        File.basename(url).chomp(File.extname(url))
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
      config['url']
    end

    def name
      File.basename(url)
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
        versions.map do |release_config|
          release_config = Release.normalize(release_config, config)
          Release.new(release_config, logger)
        end
      end
    end
  end
end