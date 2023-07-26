class RDDR::SubScreen < RDDR::GTKObject
  class Camera < RDDR::GTKObject
    EXCLUDED_ATTRIBUTES_FROM_SERIALIZATION = %i[sub_screen].freeze

    attr_reader :sub_screen, :x, :y
    attr_accessor :scale

    def initialize(sub_screen, x: 0, y: 0, scale: 1)
      @sub_screen = sub_screen

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

    def center!
      @x = 0
      @y = 0
      @center = nil
    end

    def grid_viewport
      @sub_screen.rect
    end

    # viewport in the context of the sub screen
    def sub_screen_viewport
      @sub_screen_viewport ||= to_sub_screen_space(grid_viewport)
    end

    # given a rect in grid space, converts the rect to sub screen space
    def to_sub_screen_space(grid_rect)
      sub_screen_rect_x = grid_rect.x
      sub_screen_rect_y = grid_rect.y
      sub_screen_rect_w = grid_rect.w || 0
      sub_screen_rect_h = grid_rect.h || 0

      sub_screen_rect_x = (sub_screen_rect_x - @sub_screen.half_w + @x * @scale - @sub_screen.x) / @scale
      sub_screen_rect_y = (sub_screen_rect_y - @sub_screen.half_h + @y * @scale - @sub_screen.y) / @scale
      sub_screen_rect_w = sub_screen_rect_w / @scale
      sub_screen_rect_h = sub_screen_rect_h / @scale

      grid_rect.merge(x: sub_screen_rect_x, y: sub_screen_rect_y, w: sub_screen_rect_w, h: sub_screen_rect_h)
    end

    # given a rect in sub screen space, converts the rect to grid space
    def to_grid_space(sub_screen_rect)
      grid_rect_x = sub_screen_rect.x
      grid_rect_y = sub_screen_rect.y
      grid_rect_w = sub_screen_rect.w || 0
      grid_rect_h = sub_screen_rect.h || 0

      grid_rect_x = grid_rect_x * @scale - @x * @scale + @sub_screen.half_w
      grid_rect_y = grid_rect_y * @scale - @y * @scale + @sub_screen.half_h
      grid_rect_w = grid_rect_w * @scale
      grid_rect_h = grid_rect_h * @scale

      sub_screen_rect.merge(x: grid_rect_x, y: grid_rect_y, w: grid_rect_w, h: grid_rect_h)
    end

    # helper method to find rects or objects (need a block) within viewport
    def filter_visible_rects(objects)
      if block_given?
        objects.each { |object| Geometry.intersect_rect?(sub_screen_viewport, yield(object)) }
      else
        Geometry.find_all_intersect_rect(sub_screen_viewport, objects)
      end
    end
  end
end
