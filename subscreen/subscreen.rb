class RDDR::Subscreen < RDDR::GTKObject
  include RDDR::Subscreen::Shakeable
  include RDDR::Subscreen::Resizeable

  EXCLUDED_ATTRIBUTES_FROM_SERIALIZATION = %i[entities].freeze

  attr_accessor :rect
  attr_reader :buffer_name, :target, :entities, :world_grid

  def initialize(buffer_name, rect: {}, target: nil, world_grid_scale: 1)
    @buffer_name = buffer_name

    @rect = rect

    @rect.w = grid.w     unless @rect.w
    @rect.h = grid.h     unless @rect.h
    center!(:horizontal) unless @rect.x
    center!(:vertical)   unless @rect.y

    @target = target

    @entities = Hash.new { |h, k| h[k] = [] }

    @world_grid =
      camera # initialize camera
      .world_viewport
      .scale_rect_extended(
        percentage_x: world_grid_scale.is_a?(Hash) ? world_grid_scale.x : world_grid_scale,
        percentage_y: world_grid_scale.is_a?(Hash) ? world_grid_scale.y : world_grid_scale,
        anchor_x: 0.5, anchor_y: 0.5
      )

    @initial_rect = @rect.dup

    init_shaking!

    return if gtk.production?

    state.render_targets ||= []
    state.render_targets << @buffer_name
    state.render_targets << @target if @target
    state.render_targets.uniq!
  end

  def half_w
    @rect.w / 2
  end

  def half_h
    @rect.h / 2
  end

  def x
    @rect.x
  end

  def y
    @rect.y
  end

  def w
    @rect.w
  end

  def h
    @rect.h
  end

  def x=(value)
    @rect.x = value
  end

  def y=(value)
    @rect.y = value
  end

  def w=(value)
    render_target.w = @rect.w = value

  end

  def h=(value)
    render_target.h = @rect.h = value
  end

  def center!(option = :both)
    @rect.x = (grid.w - @rect.w) / 2 if option == :both || option == :horizontal
    @rect.y = (grid.h - @rect.h) / 2 if option == :both || option == :vertical
  end

  def camera
    @camera ||= RDDR::Subscreen::Camera.new(self)
  end

  def world_viewport
    from_grid_to_world_space(@rect)
  end

  def random_world_point
    {
      x: rand(world_grid.left..world_grid.right), y: rand(world_grid.bottom..world_grid.top),
      w: 0, h: 0,
    }
  end

  def all_entities(only_visible: false, only_collidable: false)
    @entities
      .values
      .tap(&:flatten!)
      .tap do |entities|
        entities.reject! do |entity|
          (only_visible && !entity.visible?) || (only_collidable && !entity.collidable?)
        end
      end
  end

  def viewport_entities(...)
    world_viewport = world_viewport()

    all_entities(...).select { Geometry.intersect_rect?(world_viewport, _1) }
  end

  def entities_collisions(only_viewport: false, only_visible: false, only_collidable: true, radius_ratio: false)
    entities =
      if only_viewport
        viewport_entities(only_visible: only_visible, only_collidable: only_collidable)
      else
        all_entities(only_visible: only_visible, only_collidable: only_collidable)
      end

    Geometry.find_all_collisions(entities, radius_ratio: radius_ratio)
  end

  def entities_tick
    @entities.each_value.each { _1.each(&:tick) }
  end

  def from_grid_to_subscreen_space(grid_rect)
    subscreen_rect_x = grid_rect.x
    subscreen_rect_y = grid_rect.y
    subscreen_rect_w = grid_rect.w || 0
    subscreen_rect_h = grid_rect.h || 0

    subscreen_rect_x = subscreen_rect_x - @rect.x
    subscreen_rect_y = subscreen_rect_y - @rect.y
    subscreen_rect_w = subscreen_rect_w
    subscreen_rect_h = subscreen_rect_h

    grid_rect.merge(x: subscreen_rect_x, y: subscreen_rect_y, w: subscreen_rect_w, h: subscreen_rect_h)
  end

  def from_subscreen_to_grid_space(subscreen_rect)
    grid_rect_x = subscreen_rect.x
    grid_rect_y = subscreen_rect.y
    grid_rect_w = subscreen_rect.w || 0
    grid_rect_h = subscreen_rect.h || 0

    grid_rect_x = grid_rect_x + @rect.x
    grid_rect_y = grid_rect_y + @rect.y
    grid_rect_w = grid_rect_w
    grid_rect_h = grid_rect_h

    subscreen_rect.merge(x: grid_rect_x, y: grid_rect_y, w: grid_rect_w, h: grid_rect_h)
  end

  def from_subscreen_to_world_space(subscreen_rect)
    @camera.to_world_space(subscreen_rect)
  end

  def from_world_to_subscreen_space(world_rect)
    @camera.to_subscreen_space(world_rect)
  end

  def from_grid_to_world_space(grid_rect)
    from_subscreen_to_world_space(from_grid_to_subscreen_space(grid_rect))
  end

  def from_world_to_grid_space(world_rect)
    from_subscreen_to_grid_space(from_world_to_subscreen_space(world_rect))
  end

  def fullscreen?
    @rect.values_at(:x, :y, :w, :h) == grid.rect
  end

  def toggle_fullscreen!
    start_resizing!(fullscreen? ? @initial_rect : grid.rect)
  end

  def render_target
    outputs[@buffer_name]
  end

  def pre_render
    return if state.tick_count == @last_prerender

    render_target.transient!
    render_target.w = @rect.w
    render_target.h = @rect.h

    shaking!
    easing_resize!

    @last_prerender = state.tick_count
  end

  def buffer
    pre_render

    { **@rect, path: @buffer_name }
  end

  def render
    if @target
      outputs[@target].primitives << buffer
    else
      outputs.primitives << buffer
    end
  end
end
