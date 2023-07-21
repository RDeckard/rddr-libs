module Timer
  extend self

  def throttle(...)
    Throttle.new(...)
  end

  class Throttle < RDDR::GTKObject
    # delay: in seconds
    # leading: start with the first call or not
    def initialize(delay, leading = false, &block)
      @delay = case delay
               when Numeric
                 delay * 60
               when Range
                 (delay.min * 60)..(delay.max * 60)
               end
      @leading = leading
      @block = block
    end

    def call
      return false if elapsed_time < delay

      @last_yield_at = state.tick_count
      delay(:reset)
      @block.nil? ? true : @block.call
    end

    def reset!
      @last_yield_at = nil
      delay(:reset)
    end

    private

    def elapsed_time
      state.tick_count - last_yield_at
    end

    def last_yield_at
      @last_yield_at ||= @leading ? -delay(:max) : state.tick_count
    end

    def delay(option = nil)
      return @stored_delay = nil if option == :reset

      case @delay
      when Numeric
        @delay
      when Range
        case option
        when :min then @delay.min
        when :max then @delay.max
        else
          @stored_delay ||= rand(@delay)
        end
      end
    end
  end
end
