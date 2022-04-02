module Timer
  extend self

  def throttle(...)
    Throttle.new(...)
  end

  class Throttle < RDDR::GTKObject
    def initialize(delay, leading = false, &block)
      @delay   = delay * 60
      @leading = leading
      @block   = block
    end

    def call
      return if elapsed_time < @delay

      @last_yield_at = state.tick_count
      @block.call
    end

    def elapsed_time
      state.tick_count - last_yield_at
    end

    def last_yield_at
      @last_yield_at ||= @leading ? -@delay : state.tick_count
    end
  end
end
