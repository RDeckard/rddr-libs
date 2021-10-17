class Button < GTKObject
  attr_accessor :x, :y, :w, :h
  attr_reader   :box

  def initialize(x: 0, y: 0, w:, h: 0, text: nil, text_size: 1)
    @x = x
    @y = y
    @w = w
    @h = h

    @text = text
    @text_size = text_size
    @text_rect = %i[w h].zip(gtk.calcstringbox(text, @text_size)).to_h

    @h = 2*@text_rect.h if @text

    primitives
  end

  def primitive_marker
    :solid
  end

  def primitives
    primitives = []

      # Box for the slide
    @box = { x: @x, y: @y, w: @w, h: @h }.solid!(r: 192, g: 192, b: 192)
    primitives << @box

    if @text
      @label = { text: @text, size_enum: @text_size, r: 128, g: 128, b: 128 }.label!(@text_rect)
      @label.merge!(geometry.center_inside_rect(@label, @box)).merge!(y: @label.top)
      primitives << @label
    end

    primitives
  end

  def handler_inputs
    yield if inputs.mouse.up&.inside_rect?(@box)

    # TO TEST
    if inputs.finger_one&.inside_rect?(@box)
      @touch = true
    elsif @touch && inputs.finger_one.nil?
      yield
    else
      @touch = false
    end
  end
end
