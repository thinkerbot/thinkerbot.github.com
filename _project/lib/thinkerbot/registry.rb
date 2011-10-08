require 'thinkerbot/release'
require 'yaml'

module Thinkerbot
  class Registry
    class << self
      def config_file(root_dir)
        File.expand_path('_project/config/projects.yml', root_dir)
      end

      def setup(root_dir, logger)
        repos = YAML.load_file(config_file(root_dir))
        new root_dir, repos, logger
      end
    end
    include Utils

    attr_reader :root_dir
    attr_reader :logger
    attr_reader :repos

    def initialize(root_dir, repos, logger)
      @root_dir = root_dir
      @logger   = logger
      @repos    = repos
      @releases = {}
    end

    def project_name(repo)
      File.basename(repo)
    end

    def versions(name)
      list = log_sh "gem list -a --remote #{name}"
      list =~ /^#{name} \((.*)\)$/
      $1.to_s.split(', ')
    end

    def releases(repo)
      @releases[repo] ||= begin
        name = project_name(repo)
        versions(name).map do |version|
          Release.new(name, version, logger)
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
      repos.each do |repo|
        releases(repo).each do |release|
          yield release
        end
      end
    end
  end
end