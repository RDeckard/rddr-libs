class RDDR::Subscreen
  module Entity
    include RDDR::Spriteable

    EXCLUDED_ATTRIBUTES_FROM_SERIALIZATION = %i[subscreen camera].freeze

    ANCHOR = { x: 0.5, y: 0.5 }.freeze
    ANGLE_OFFSET = 0

    COLLIDABLE = false

    attr_accessor :collidable
    attr_reader :subscreen, :camera

    def self.included(base)
      base.extend ClassMethods
    end

    def initialize(subscreen, x: 0, y: 0, world_angle: nil, collidable: self.class::COLLIDABLE, **kwargs)
      super(**kwargs)

      @subscreen = subscreen
      @subscreen.entities[type] << self

      @camera = subscreen.camera

      @x = x
      @y = y

      self.world_angle = world_angle if world_angle

      @collidable = collidable
    end

    # to be overriden by subclasses
    def tick
      destroy! if tile_index.zero?

      @last_tile_index = tile_index
    end

    def collidable?
      @collidable
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
      @subscreen.entities[type].delete(self)
    end

    def subscreen_rect
      @camera.to_subscreen_space(rect)
    end

    def subscreen_shape_rect
      @camera.to_subscreen_space(shape_rect)
    end

    def draw_parameters
      subscreen_rect
    end

    # Can be overriden by subclasses
    def type
      self.class.type
    end

    module ClassMethods
      def type
        @type ||= name.to_sym
      end
    end
  end
end
