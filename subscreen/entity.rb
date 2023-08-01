class RDDR::Subscreen
  module Entity
    include RDDR::Spriteable

    ANCHOR = { x: 0.5, y: 0.5 }.freeze
    ANGLE_OFFSET = 90

    attr_reader :subscreen, :camera

    def initialize(subscreen, x: 0, y: 0, **kwargs)
      super(**kwargs)

      @subscreen = subscreen
      @subscreen.entities << self

      @camera = subscreen.camera

      @x = x
      @y = y
    end

    def world_angle
      (angle + self.class::ANGLE_OFFSET).mod(360)
    end

    def world_angle=(value)
      self.angle = value - self.class::ANGLE_OFFSET
    end

    def world_grid
      @subscreen.world_grid
    end

    def destroy!
      @subscreen.entities.delete(self)
    end

    def subscreen_rect
      @camera.to_subscreen_space(rect)
    end

    def draw_parameters
      subscreen_rect
    end
  end
end
