require 'thinkerbot/utils'
require 'fileutils'

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

    def gem_file(version)
      "#{name}-#{version}.gem"
    end

    def fetch(version, force=false)
      gemfile = gem_file(version)

      if !File.exists?(gemfile) || force
        FileUtils.rm_f gemfile
        log_sh "gem fetch #{name} -v #{version}"
      end

      gemfile
    end

    def unpack(version)
      log_sh %Q{gem unpack '#{gem_file(version)}' --backtrace}
    end
  end
end