require 'thinkerbot/utils'
require 'fileutils'

module Thinkerbot
  class Release
    include Utils

    attr_reader :name
    attr_reader :version

    def initialize(name, version, logger=nil)
      @name = name
      @version = version
      @logger = logger
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
          files =  gemspec.files.select {|file| File.extname(file) == '.rb' }
          files += gemspec.extra_rdoc_files
          opts  =  gemspec.rdoc_options
          log_sh "rdoc -o '#{rdoc_dir}' '#{opts.join("' '")}' '#{files.join("' '")}'".gsub("''", "")
        end
      end

      rdoc_dir
    end
  end
end