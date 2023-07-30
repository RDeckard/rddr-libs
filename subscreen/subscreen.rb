class RDDR::Subscreen < RDDR::GTKObject
  include RDDR::Subscreen::Shakeable

  EXCLUDED_ATTRIBUTES_FROM_SERIALIZATION = %i[entities].freeze

  attr_reader :x, :y, :w, :h, :buffer_name, :target, :entities

  def initialize(buffer_name, x: nil, y: nil, w: grid.w, h: grid.h, target: nil)
    @buffer_name = buffer_name

    @w = w
    @h = h
    @target = target

    @entities = []

    x ? @x = x : center!(:horizontal)
    y ? @y = y : center!(:vertical)

    init_shaking!
  end

  def rect
    @rect ||= { x: @x, y: @y, w: @w, h: @h }
  end

  def half_w
    @half_w ||= @w / 2
  end

  def half_h
    @half_h ||= @h / 2
  end

  def x=(value)
    @x = value
    @rect = nil
  end

  def y=(value)
    @y = value
    @rect = nil
  end

  def w=(value)
    render_target.w = @w = value
    @rect = nil
    @half_w = nil
  end

  def h=(value)
    render_target.h = @h = value
    @rect = nil
    @half_h = nil
  end

  def center!(option = :both)
    @x = (grid.w - @w) / 2 if option == :horizontal
    @y = (grid.h - @h) / 2 if option == :vertical

    @rect = nil
  end

  def camera
    @camera ||= RDDR::Subscreen::Camera.new(self)
  end

  def world_viewport
    from_grid_to_world_space(rect)
  end

  def visible_entities
    @camera.visible_entities
  end

  def from_grid_to_subscreen_space(grid_rect)
    subscreen_rect_x = grid_rect.x
    subscreen_rect_y = grid_rect.y
    subscreen_rect_w = grid_rect.w || 0
    subscreen_rect_h = grid_rect.h || 0

    subscreen_rect_x = subscreen_rect_x - @x
    subscreen_rect_y = subscreen_rect_y - @y
    subscreen_rect_w = subscreen_rect_w
    subscreen_rect_h = subscreen_rect_h

    grid_rect.merge(x: subscreen_rect_x, y: subscreen_rect_y, w: subscreen_rect_w, h: subscreen_rect_h)
  end

  def from_subscreen_to_grid_space(subscreen_rect)
    grid_rect_x = subscreen_rect.x
    grid_rect_y = subscreen_rect.y
    grid_rect_w = subscreen_rect.w || 0
    grid_rect_h = subscreen_rect.h || 0

    grid_rect_x = grid_rect_x + @x
    grid_rect_y = grid_rect_y + @y
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

  def render_target
    outputs[@buffer_name]
  end

  def pre_render
    return if state.tick_count == @last_prerender

    render_target.transient!
    render_target.w = @w
    render_target.h = @h

    shaking!

    @last_prerender = state.tick_count
  end

  def buffer
    pre_render

    { **rect, path: @buffer_name }
  end

  def render
    if @target
      outputs[@target].primitives << buffer
    else
      outputs.primitives << buffer
    end
  end
end
