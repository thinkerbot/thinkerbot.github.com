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
  end
end