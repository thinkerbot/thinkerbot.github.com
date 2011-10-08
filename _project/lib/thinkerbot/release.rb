require 'thinkerbot/utils'
require 'fileutils'

module Thinkerbot
  class Release
    class << self
      def normalize(config, default={})
        if config.kind_of?(String)
          config = {'version' => config}
        end

        default.merge(config)
      end

      def default_rubies
        @default_rubies ||= [`ruby -v`.split[0,2].join('-')]
      end
    end

    include Utils

    attr_reader :config

    def initialize(config, logger=nil)
      @config = config
      @logger = logger
    end

    def name
      config['name']
    end

    def version
      config['version']
    end

    def default_ruby
      config['ruby'] ||= rubies.first
    end

    # The command used to generate rdoc for the release.  The command is
    # formatted using % with the rdoc_options and documentable files as in the
    # gemspec, and should produce an 'rdoc' dir.
    #
    # In this context "documentable" means all .rb files in the gemspec (hence
    # it assumes there are NOT any tests in the gem), plus any extra_rdoc_files.
    def rdoc_cmd
      config['rdoc'] ||= "rdoc -o rdoc %s %s"
    end

    def rcov_cmd
      config['rcov'] ||= ""
    end

    def rubies
      config['rubies'] ||= self.class.default_rubies
    end

    def gemfile
      @gemfile ||= File.expand_path("#{name}-#{version}.gem")
    end

    def gemspec
      @gemspec ||= begin
        spec = log_sh "gem specification '#{gemfile}' --ruby --backtrace"
        eval(spec)
      end
    end

    def code_dir
      @code_dir ||= File.expand_path(gemspec.full_name)
    end

    def rdoc_dir
      @rdoc_dir ||= File.expand_path(File.join(gemspec.name, gemspec.version.to_s, 'rdoc'))
    end

    def fetch(force=false)
      if !File.exists?(gemfile) || force
        FileUtils.rm_f gemfile
        log_sh "gem fetch #{name} -v #{version}"
      end

      gemfile
    end

    def unpack(force=false)
      if !File.exists?(code_dir) || force
        FileUtils.rm_rf code_dir
        log_sh %Q{gem unpack '#{gemfile}' --backtrace}
      end
    end

    def build_rdoc(force=false)
      if !File.exists?(rdoc_dir) || force
        FileUtils.rm_rf rdoc_dir
        FileUtils.mkdir_p File.dirname(rdoc_dir)

        Dir.chdir(code_dir) do
          opts   = gemspec.rdoc_options
          files  = gemspec.files.select {|file| File.extname(file) == '.rb' }
          files += gemspec.extra_rdoc_files

          log_sh rdoc_cmd % [arg_str(opts), arg_str(files)]
          FileUtils.mv 'rdoc', rdoc_dir
        end
      end

      rdoc_dir
    end
  end
end