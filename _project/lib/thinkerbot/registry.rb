require 'thinkerbot/project'
require 'yaml'

module Thinkerbot
  class Registry
    class << self
      def config_file(root_dir)
        File.expand_path('_project/config/projects.yml', root_dir)
      end

      def setup(root_dir, logger)
        config = YAML.load_file(config_file(root_dir))
        new root_dir, config, logger
      end

      def normalize(config, default={})
        default.merge(config)
      end
    end
    include Utils

    attr_reader :root_dir
    attr_reader :logger
    attr_reader :config

    def initialize(root_dir, config, logger)
      @root_dir = root_dir
      @config   = config
      @logger   = logger
    end

    def projects
      @projects ||= begin
        projects = config['projects'] || []
        projects.map do |project_config|
          project_config = Project.normalize(project_config, config)
          Project.new(project_config, logger)
        end
      end
    end

    def path(*relative_path)
      File.join(root_dir, *relative_path)
    end

    def chdir(*relative_path, &block)
      dir = path(*relative_path)

      unless File.exists?(dir)
        FileUtils.mkdir_p(dir)
      end

      Dir.chdir(dir, &block)
    end

    def each_release
      projects.each do |project|
        project.releases.each do |release|
          yield release
        end
      end
    end
  end
end