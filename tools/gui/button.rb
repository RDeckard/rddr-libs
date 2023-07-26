class RDDR::Button < RDDR::GTKObject
  attr_reader   :text
  attr_accessor :rect

  def initialize(text: nil, text_size: 1, rect: { x: 0, y: 0, w: 0, h: 0 })
    @text_size = text_size
    @rect      = rect
    self.text  = text

    @rect.h = 2*@text_rect.h if @text
  end

  def text=(text)
    @text = text
    @text_rect = %i[w h].zip(gtk.calcstringbox(text, @text_size)).to_h

    @rect.w = @text_rect.w + @text_rect.h if @text_rect.w > @rect.w
  end

  def primitives
    primitives = []

    primitives << RDDR::Box.new(@rect, background_color: :silver).primitives

    if @text
      @label = { text: @text, size_enum: @text_size, **RDDR.color(:grey) }.label!(@text_rect)
      @label.merge!(Geometry.center_inside_rect(@label, @rect)).merge!(y: @label.top)
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
