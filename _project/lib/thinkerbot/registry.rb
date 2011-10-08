require 'thinkerbot/project'
require 'yaml'

module Thinkerbot
  class Registry
    class << self
      def config_file(root_dir)
        File.expand_path('_project/config/projects.yml', root_dir)
      end

      def setup(root_dir, logger)
        new root_dir, YAML.load_file(config_file(root_dir)), logger
      end
    end

    attr_reader :root_dir
    attr_reader :logger
    attr_reader :projects

    def initialize(root_dir, projects, logger)
      @root_dir = root_dir
      @logger   = logger
      @projects = projects.map {|path| Project.new(path, logger) }
    end

    def project_path(relative_path)
      File.join(root_dir, '_project', relative_path)
    end
  end
end