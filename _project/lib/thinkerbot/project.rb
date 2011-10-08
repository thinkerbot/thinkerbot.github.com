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

    def gem_spec(version)
      gemfile = gem_file(version)
      gemspec = log_sh "gem specification '#{gemfile}' --ruby --backtrace"
      eval(gemspec)
    end

    def code_dir(version)
      gemspec = gem_spec(version)
      gemspec.full_name
    end

    def rdoc_dir(version)
      gemspec  = gem_spec(version)
      rdoc_dir = File.join(gemspec.name, gemspec.version.to_s, 'rdoc')
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

    def build_rdoc(version, force=false)
      gemspec = gem_spec(version)
      codedir = code_dir(version)
      rdocdir = File.expand_path rdoc_dir(version)

      if !File.exists?(rdocdir) || force
        FileUtils.rm_rf rdocdir
        FileUtils.mkdir_p File.dirname(rdocdir)

        Dir.chdir(codedir) do
          files =  gemspec.files.select {|file| File.extname(file) == '.rb' }
          files += gemspec.extra_rdoc_files
          opts  =  gemspec.rdoc_options
          log_sh "rdoc -o '#{rdocdir}' '#{opts.join("' '")}' '#{files.join("' '")}'".gsub("''", "")
        end
      end
    end
  end
end