class RDDR::SubScreen < RDDR::GTKObject
  include RDDR::SubScreen::Shakeable

  attr_reader :x, :y, :w, :h, :buffer_name

  def initialize(buffer_name, x: nil, y: nil, w: grid.w, h: grid.h, target: nil)
    @buffer_name = buffer_name

    @w = w
    @h = h
    @target = target

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
    buffer.w = @w = value
    @rect = nil
    @half_w = nil
  end

  def h=(value)
    buffer.h = @h = value
    @rect = nil
    @half_h = nil
  end

  def center!(option = :both)
    @x = (grid.w - @w) / 2 if option == :horizontal
    @y = (grid.h - @h) / 2 if option == :vertical

    @rect = nil
  end

  def camera
    @camera ||= RDDR::SubScreen::Camera.new(self)
  end

  def buffer
    outputs[@buffer_name]
  end

  def primitives
    pre_render

    { **rect, path: @buffer_name }
  end

  def pre_render
    return if state.tick_count == @last_prerender

    buffer.transient!
    buffer.w = @w
    buffer.h = @h

    shaking!

    @last_prerender = state.tick_count
  end

  def render
    if @target
      outputs[@target].primitives << primitives
    else
      outputs.primitives << primitives
    end
  end
end
