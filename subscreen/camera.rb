class RDDR::Subscreen
  class Camera < RDDR::GTKObject
    EXCLUDED_ATTRIBUTES_FROM_SERIALIZATION = %i[subscreen].freeze

    attr_reader :subscreen, :x, :y
    attr_accessor :scale

    def initialize(subscreen, x: 0, y: 0, scale: 1)
      @subscreen = subscreen

      @x = x
      @y = y
      @scale = scale
    end

    def center
      @center ||= { x: @x, y: @y }
    end

    def x=(value)
      @x = value
      @center = nil
    end

    def y=(value)
      @y = value
      @center = nil
    end

    def center!(entity = nil)
      @x = entity&.x || 0
      @y = entity&.y || 0
      @center = nil
    end

    # viewport in the context of the world
    def world_viewport
      @subscreen.world_viewport
    end

    # given a rect in subscreen space, converts the rect to world space
    def to_world_space(subscreen_rect)
      world_rect_x = subscreen_rect.x
      world_rect_y = subscreen_rect.y
      world_rect_w = subscreen_rect.w || 0
      world_rect_h = subscreen_rect.h || 0

      world_rect_x = (world_rect_x - @subscreen.half_w) / @scale + @x
      world_rect_y = (world_rect_y - @subscreen.half_h) / @scale + @y
      world_rect_w = world_rect_w / @scale
      world_rect_h = world_rect_h / @scale

      subscreen_rect.merge(x: world_rect_x, y: world_rect_y, w: world_rect_w, h: world_rect_h)
    end

    # given a rect in world space, converts the rect to subscreen space
    def to_subscreen_space(world_rect)
      subscreen_rect_x = world_rect.x
      subscreen_rect_y = world_rect.y
      subscreen_rect_w = world_rect.w || 0
      subscreen_rect_h = world_rect.h || 0

      subscreen_rect_x = (subscreen_rect_x - @x) * @scale + @subscreen.half_w
      subscreen_rect_y = (subscreen_rect_y - @y) * @scale + @subscreen.half_h
      subscreen_rect_w = subscreen_rect_w * @scale
      subscreen_rect_h = subscreen_rect_h * @scale

      world_rect.merge(x: subscreen_rect_x, y: subscreen_rect_y, w: subscreen_rect_w, h: subscreen_rect_h)
    end

    def visible_entities
      @subscreen.entities.select { |entity| Geometry.intersect_rect?(world_viewport, entity.rect) }
    end

    # helper method to find rects or objects (need a block) within viewport
    def filter_visible_rects(objects)
      world_viewport = world_viewport()

      if block_given?
        objects.select { |object| Geometry.intersect_rect?(world_viewport, yield(object)) }
      else
        Geometry.find_all_intersect_rect(world_viewport, objects)
      end
    end
  end
end
