require 'logger'

module Thinkerbot
  module Utils
    def logger
      @logger ||= Logger.new($stdout)
    end

    def log_sh(str)
      logger.info "$ #{str}"
      `#{str}`
    end

    def chdir(dir, &block)
      unless File.exists?(dir)
        FileUtils.mkdir_p(dir)
      end
      Dir.chdir(dir, &block)
    end
  end
end