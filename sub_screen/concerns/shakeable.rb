class RDDR::SubScreen < RDDR::GTKObject
  module Shakeable
    def trauma!(amount)
      @trauma += amount
    end

    private

    def shaking!
      return init_shaking! if @trauma.zero?

      next_angle = 180.0 / 20.0 * @trauma**2
      next_offset = 100.0 * @trauma**2

      # Ensure that the sub screen angle always switches from
      # positive to negative and vice versa
      # which gives the effect of shaking back and forth
      @angle = @angle > 0 ? next_angle * -1 : next_angle

      @x_offset = next_offset.randomize(:sign, :ratio)
      @y_offset = next_offset.randomize(:sign, :ratio)

      # Gracefully degrade trauma
      @trauma *= 0.95
      @trauma = 0 if @trauma < 0.01

      @rect.merge!(
        x: @x + @x_offset,
        y: @y + @y_offset,
        angle: @angle,
        path: @buffer_name,
      )
    end

    def init_shaking!
      @trauma = 0
      @angle = 0
      @x_offset = 0
      @y_offset = 0
    end
  end
end
