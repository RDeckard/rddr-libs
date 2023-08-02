class RDDR::Subscreen
  class Camera < RDDR::GTKObject
    EXCLUDED_ATTRIBUTES_FROM_SERIALIZATION = %i[subscreen].freeze

    attr_reader :subscreen, :x, :y
    attr_accessor :scale, :world_grid_bounded

    def initialize(subscreen, x: 0, y: 0, scale: 1)
      @subscreen = subscreen

      @x = x
      @y = y
      @scale = scale

      @world_grid_bounded = true
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
      return unless @world_grid_bounded

      world_grid = world_grid()
      world_viewport = world_viewport()
      half_w = world_viewport.w / 2
      half_h = world_viewport.h / 2
      @x = @x.clamp(world_grid.left + half_w, world_grid.right - half_w)
      @y = @y.clamp(world_grid.bottom + half_h, world_grid.top - half_h)
    end

    # viewport in the context of the world
    def world_viewport
      @subscreen.world_viewport
    end

    def world_grid
      @subscreen.world_grid
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
      @subscreen
        .flatten_entities
        .select { |entity| Geometry.intersect_rect?(world_viewport, entity.rect) }
    end

    # Find rects (or anything responding to #rect) or objects (need a block) within viewport
    def filter_visible_rects(objects)
      world_viewport = world_viewport()

      if block_given?
        objects.select { |object| Geometry.intersect_rect?(world_viewport, yield(object)) }
      else
        Geometry.find_all_intersect_rect(world_viewport, objects)
      end
    end

    def entities_collisions(only_visible: false, radius_ratio: false)
      if only_visible
        rect_collisions(visible_entities, radius_ratio: radius_ratio)
      else
        rect_collisions(@subscreen.flatten_entities, radius_ratio: radius_ratio)
      end
    end

    # Find all collisions of rect (or anything responding to #rect) or objects (need a block)
    # Give an optional radius_ratio if you want to use a circle instead of a rect (proportionally to the rect larger side)
    def rect_collisions(objects, radius_ratio: false)
      objects = objects.dup
      collisions = []

      until objects.empty?
        object1 = block_given? ? yield(objects.shift) : objects.shift

        collided_objects, objects =
          objects.partition do |object2|
            object2 = block_given? ? yield(object2) : object2

            if radius_ratio
              o1_collision_dist = object1.w.greater(object1.h)
              o2_collision_dist = object2.w.greater(object2.h)
              collision_distance = (o1_collision_dist + o2_collision_dist) * radius_ratio

              Geometry.distance(object1, object2) <= collision_distance
            else
              Geometry.intersect_rect?(object1, object2)
            end
          end

        collisions << collided_objects.unshift(object1) if collided_objects.any?
      end

      collisions
    end
  end
end
