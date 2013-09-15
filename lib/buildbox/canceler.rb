module Buildbox
  class Canceler
    def self.cancel(build)
      new(build).cancel
    end

    def initialize(build)
      @build = build
    end

    def cancel
      @build.cancel_started = true

      # Kill that damn process, yo!
      Process.kill 'INT', @build.pid
    end
  end
end