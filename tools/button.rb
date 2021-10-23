class RDDR::Button < RDDR::GTKObject
  attr_accessor :x, :y, :w, :h
  attr_reader   :frame

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

    @frame = { x: @x, y: @y, w: @w, h: @h }
    primitives << RDDR::Frame.new(@frame, background_color: :silver).primitives

    if @text
      @label = { text: @text, size_enum: @text_size, r: 128, g: 128, b: 128 }.label!(@text_rect)
      @label.merge!(geometry.center_inside_rect(@label, @frame)).merge!(y: @label.top)
      primitives << @label
    end

    primitives
  end

  def handler_inputs
    yield if inputs.mouse.up&.inside_rect?(@frame)

    # TO TEST
    if inputs.finger_one&.inside_rect?(@frame)
      @touch = true
    elsif @touch && inputs.finger_one.nil?
      yield
    else
      @touch = false
    end
  end
end
