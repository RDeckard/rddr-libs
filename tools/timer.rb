module RDDR::Timer
  extend self

  def throttle(...)
    Throttle.new(...)
  end

  def tick_count
    @tick_count ||= $gtk.args.state.tick_count
  end

  def tick!
    @tick_count ||= $gtk.args.state.tick_count
    @tick_count += 1
  end

  def tick_pause!
    @tick_pause = true
  end

  def tick_resume!
    @tick_pause = false
  end

  def tick_toggle!
    @tick_pause = !@tick_pause
  end

  def tick_pause?
    @tick_pause ||= false
  end

  class Throttle < RDDR::GTKObject
    # delay: in seconds
    # leading: start with the first call or not
    def initialize(delay, gameplay_time: false, leading: false, &block)
      @delay = case delay
               when Numeric
                 delay * 60
               when Range
                 (delay.min * 60)..(delay.max * 60)
               end

      @gameplay_time = gameplay_time
      @leading = leading
      @block = block
    end

    def call
      return false if elapsed_time < delay

      @last_yield_at = tick_count
      delay(:reset)
      @block.nil? ? true : @block.call
    end

    def reset!
      @last_yield_at = nil
      delay(:reset)
    end

    private

    def elapsed_time
      tick_count - last_yield_at
    end

    def last_yield_at
      @last_yield_at ||= @leading ? -delay(:max) : tick_count
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

    def tick_count
      @gameplay_time ? RDDR::Timer.tick_count : state.tick_count
    end
  end
end
