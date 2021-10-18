class Slider < GTKObject
  attr_accessor :x, :y, :w, :h
  attr_reader   :bar, :slide

  def initialize(x:, y:, w:, h:, min_value: 0, max_value: 1, text: nil, text_size: 1)
    @x = x
    @y = y
    @w = w
    @h = h

    @text = text
    @text_size = text_size

    @h = 2*gtk.calcstringbox(text, @text_size).last if @text

    @value_offset = min_value
    @value_factor = max_value - min_value

    primitives
  end

  def primitive_marker
    :solid
  end

  def primitives
    primitives = []

      # Bar for the slide
    @bar = { x: @x, y: @y, w: @w, h: @h/2 }.solid!(r: 192, g: 192, b: 192)
    primitives << @bar

    if @text
      @label = { x: @bar.x + @bar.h/2, y: @bar.top, text: @text, size_enum: @text_size, r: 128, g: 128, b: 128 }.label!
      primitives << @label
    end

    # Slide
    @slide = { w: @h, h: @h }.solid!(r: 64, g: 64, b: 64)
    @slide.merge!(geometry.center_inside_rect(@slide, @bar))
    primitives << @slide

    primitives
  end

  def handler_inputs
    if inputs.pointer.left_click&.inside_rect?(@slide)
      gtk.hide_cursor
      inputs.mouse.x = @slide.x + @slide.w/2
      @grab_slider = true
    end

    if @grab_slider && inputs.mouse.button_left
      @slide.x = inputs.mouse.x - @slide.w/2
      @slide.x = @bar.left if @slide.x < @bar.left
      @slide.x = @bar.right - @slide.w if @slide.right > @bar.right

      if inputs.pointer.left_click || inputs.mouse.moved
        yield @value_factor*(@slide.x - @bar.left) / (@bar.right - @slide.w - @bar.left) + @value_offset
      end

      return # keep hide the cursor
    elsif inputs.mouse.up
      @grab_slider = false
    end

    gtk.show_cursor # ensure to show the cursor by default
  end
end
