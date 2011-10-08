require 'thinkerbot/release'

module Thinkerbot
  class Project
    include Utils

    attr_reader :config
    attr_reader :logger

    def initialize(config, logger)
      @config = config
      @logger = logger
    end

    def url
      config['url'] or raise "no url specified: #{self}"
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
        versions.map do |version|
          Release.new(name, version, logger)
        end
      end
    end
  end
end