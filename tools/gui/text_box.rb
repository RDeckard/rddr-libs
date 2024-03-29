class RDDR::TextBox < RDDR::GTKObject
  attr_reader :text_lines

  DEFAULT_COLOR = RDDR.color(:black).merge!(a: 255).freeze
  DEFAULT_BOX_KWARGS = { background_color: :black }.freeze

  def initialize(text_lines, text_size: 0, text_color: %i[classic white], text_alignment: :left, text_offset: 5, box_offset: 5, container_rect: grid.rect, box_alignment: :center, box_alignment_v: :center, max_width: nil, box_x: nil, box_y: nil, box_kwargs: {}, invisible_box: false)
    @text_lines      = (text_lines.is_a?(String) ? text_lines.split("\n") : text_lines).flatten
    @text_size       = text_size
    @text_color      = text_color
    @text_alignment  = text_alignment
    @text_offset     = text_offset
    @box_offset      = box_offset
    @container_rect  = container_rect
    @box_alignment   = box_alignment
    @box_alignment_v = box_alignment_v
    @max_width       = max_width || container_rect.w
    @box_x           = box_x
    @box_y           = box_y
    @box_kwargs      = box_kwargs
    @invisible_box   = invisible_box || false

    @text_color =
      if @text_color.is_a?(Hash)
        DEFAULT_COLOR.merge(@text_color)
      else
        RDDR.color(@text_color)
      end

    yield(self) if block_given?

    primitives
  end

  def primitives
    return @primitives if @primitives

    @primitives = []

    rect.x ||=
      case @box_alignment
      when Numeric then @box_alignment
      when :center then Geometry.center_inside_rect_x(rect, @container_rect).x
      when :left   then @container_rect.left.shift_right(@box_offset)
      when :right  then @container_rect.right.shift_left(@box_offset + rect.w)
      end

    rect.y ||=
      case @box_alignment_v
      when Numeric then @box_alignment_v
      when :center then Geometry.center_inside_rect_y(rect, @container_rect).y
      when :top    then @container_rect.top.shift_down(@box_offset + rect.h)
      when :bottom then @container_rect.bottom.shift_up(@box_offset)
      end

    unless @invisible_box
      @primitives << RDDR::Box.new(rect, DEFAULT_BOX_KWARGS.merge(**@box_kwargs)).primitives
    end

    @primitives << @text_lines.map.with_index do |text, index|
      x =
        case @text_alignment
        when :left   then rect.x.shift_right(@text_offset)
        when :center then rect.x + 0.5*rect.w
        when :right  then (rect.x + rect.w).shift_left(@text_offset)
        end

      {
        x: x,
        y: (rect.y + rect.h).shift_down(@text_offset + @line_h*index),
        text: text,
        size_enum: @text_size,
        alignment_enum: %i[left center right].index(@text_alignment),
        **@text_color,
      }.label!
    end

    @primitives
  end

  def rect
    @rect ||= begin
      longest_text_line = @text_lines.max_by { |line| line.size } || ""
      line_w, @line_h = gtk.calcstringbox(longest_text_line, @text_size)
      line_w += 2*@text_offset
      box_w = line_w + 2*@box_offset > @max_width ? @max_width - 2*@box_offset : line_w

      max_chars_by_line =
        if line_w.positive?
          (box_w/line_w * longest_text_line.size + 1).to_i
        else
          0
        end

      @text_lines = RDDR.wrapped_lines(@text_lines, max_chars_by_line)

      @line_h += @text_offset
      box_h = @text_offset + @text_lines.size*@line_h

      { x: @box_x, y: @box_y, w: box_w, h: box_h, a: 128 }
    end
  end

  def line_rect(line_index)
    line_rindex = @text_lines.count - line_index - 1

    {
      x: rect.x,
      y: rect.y + @line_h * line_rindex,
      w: rect.w,
      h: @line_h
    }
  end

  def line_rects
    @text_lines.map.with_index { |_, index| line_rect(index) }
  end

  def text_lines=(value)
    @text_lines = value
    reset_primitives!
  end

  def reset_primitives!
    @primitives = nil
  end
end
