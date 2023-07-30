class RDDR::Subscreen < RDDR::GTKObject
  module Entity
    include RDDR::Spriteable

    ANCHOR = { x: 0.5, y: 0.5 }.freeze
    ANGLE_OFFSET = 90

    attr_reader :subscreen, :camera

    def initialize(subscreen, x: 0, y: 0, **kwargs)
      @subscreen = subscreen
      @subscreen.entities << self

      @camera = subscreen.camera

      @x = x
      @y = y

      super(**kwargs)
    end

    def world_angle
      (angle + self.class::ANGLE_OFFSET).mod(360)
    end

    def world_angle=(value)
      self.angle = value - self.class::ANGLE_OFFSET
    end

    def subscreen_rect
      @camera.to_subscreen_space(rect)
    end

    def draw_parameters
      subscreen_rect
    end
  end
end