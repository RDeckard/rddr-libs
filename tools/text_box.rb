class RDDR::TextBox < RDDR::GTKObject
  attr_reader :frame, :text_lines

  def initialize(text_lines, text_size: 0, container_rect: grid.rect, frame_alignment: :center, frame_alignment_v: :center, text_alignment: :left, text_offset: 5, frame_offset: 5, max_width: nil, frame_x: nil, frame_y: nil)
    @text_lines        = (text_lines.is_a?(String) ? text_lines.split("\n") : text_lines).flatten
    @text_size         = text_size
    @container_rect    = container_rect
    @frame_alignment   = frame_alignment
    @frame_alignment_v = frame_alignment_v
    @text_alignment    = text_alignment
    @text_offset       = text_offset
    @frame_offset      = frame_offset
    @max_width         = max_width || container_rect.w
    @frame_x           = frame_x
    @frame_y           = frame_y

    primitives
  end

  def primitives
    return @primitives if @primitives

    @primitives = []

    frame.x ||=
      case @frame_alignment
      when Numeric then @frame_alignment
      when :center then geometry.center_inside_rect_x(frame, @container_rect).x
      when :left   then @container_rect.left.shift_right(@frame_offset)
      when :right  then @container_rect.right.shift_left(@frame_offset + frame.w)
      end

    frame.y ||=
      case @frame_alignment_v
      when Numeric then @frame_alignment_v
      when :center then geometry.center_inside_rect_y(frame, @container_rect).y
      when :top    then @container_rect.top.shift_down(@frame_offset + frame.h)
      when :bottom then @container_rect.bottom.shift_up(@frame_offset)
      end

    @primitives << RDDR::Frame.new(frame, background_color: :black).primitives

    @primitives << @text_lines.map.with_index do |text, index|
      x =
        case @text_alignment
        when :left   then frame.x.shift_right(@text_offset)
        when :center then frame.x + 0.5*frame.w
        when :right  then (frame.x + frame.w).shift_left(@text_offset)
        end

      {
        x: x,
        y: (frame.y + frame.h).shift_down(@text_offset + @line_h*index),
        text: text,
        size_enum: @text_size,
        alignment_enum: %i[left center right].index(@text_alignment),
        r: 255, g: 255, b: 255
      }.label!
    end

    @primitives
  end

  def frame
    @frame ||= begin
      longest_text_line = @text_lines.max_by { |line| line.size } || ""
      line_w, @line_h = gtk.calcstringbox(longest_text_line, @text_size)
      line_w += 2*@text_offset
      frame_w = line_w + 2*@frame_offset > @max_width ? @max_width - 2*@frame_offset : line_w

      max_chars_by_line = (frame_w/line_w * longest_text_line.size).to_i

      @text_lines = RDDR.wrapped_lines(@text_lines, max_chars_by_line)

      @line_h += @text_offset
      frame_h = @text_offset + @text_lines.size*@line_h

      { x: @frame_x, y: @frame_y, w: frame_w, h: frame_h, a: 128 }
    end
  end
end
