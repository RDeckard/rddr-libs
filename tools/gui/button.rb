class RDDR::Button < RDDR::GTKObject
  attr_accessor :x, :y, :w, :h
  attr_reader   :rect

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

  def primitives
    primitives = []

    @rect = { x: @x, y: @y, w: @w, h: @h }
    primitives << RDDR::Box.new(@rect, background_color: :silver).primitives

    if @text
      @label = { text: @text, size_enum: @text_size, r: 128, g: 128, b: 128 }.label!(@text_rect)
      @label.merge!(geometry.center_inside_rect(@label, @rect)).merge!(y: @label.top)
      primitives << @label
    end

    primitives
  end

  def handle_inputs
    if inputs.pointer.inside_rect?(@rect)
      if inputs.pointer.left_click
        @clicked = true
      elsif inputs.mouse.up && @clicked
        yield
      end
    else
      @clicked = false
    end
  end
end
