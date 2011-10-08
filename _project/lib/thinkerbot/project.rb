require 'thinkerbot/utils'

module Thinkerbot
  class Project
    include Utils

    attr_reader :path
    attr_reader :name

    def initialize(path, logger=nil)
      @path = path
      @name = File.basename(path)
      @logger = logger
    end

    def versions
      @versions ||= begin
        list = log_sh "gem list -a --remote #{name}"
        list =~ /^#{name} \((.*)\)$/
        $1.to_s.split(', ')
      end
    end

    def fetch(version, opts={})
      dir = opts[:dir] || '.'
      gemfile = File.expand_path("#{name}-#{version}.gem", dir)

      if !File.exists?(gemfile) || opts[:force]
        FileUtils.rm_f gemfile

        chdir('gems') do
          log_sh "gem fetch #{name} -v #{version}"
        end
      end

      gemfile
    end
  end
end