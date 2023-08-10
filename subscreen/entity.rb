class RDDR::Subscreen
  module Entity
    include RDDR::Spriteable

    EXCLUDED_ATTRIBUTES_FROM_SERIALIZATION = %i[subscreen camera].freeze

    ANCHOR = { x: 0.5, y: 0.5 }.freeze

    COLLIDABLE = false

    attr_accessor :collidable
    attr_reader :subscreen

    def self.included(base)
      base.extend ClassMethods
    end

    def initialize(subscreen, x: 0, y: 0, collidable: self.class::COLLIDABLE, **kwargs)
      super(**kwargs)

      self.subscreen = subscreen

      @x = x
      @y = y

      @collidable = collidable
    end

    def camera
      @subscreen.camera
    end

    def subscreen=(new_subscreen)
      remove_from_subscreen! if @subscreen

      @subscreen = new_subscreen
      @subscreen.entities[type] << self
    end

    def remove_from_subscreen!
      @subscreen.entities[type].delete(self)
    end

    # to be overriden by subclasses
    def tick
      remove_from_subscreen! if animation_finished?
    end

    def collidable?
      @collidable
    end

    def world_grid
      @subscreen.world_grid
    end

    def out_of_world_grid?
      !rect.intersect_rect?(world_grid)
    end

    def subscreen_rect
      camera.to_subscreen_space(rect)
    end

    def subscreen_shape_rect
      camera.to_subscreen_space(shape_rect)
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
