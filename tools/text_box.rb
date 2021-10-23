class RDDR::TextBox < RDDR::GTKObject
  attr_reader :frame, :text_lines

  def initialize(text_lines, text_size: 0, frame_alignment: :center, frame_alignment_v: :center, text_alignment: :left, offset: 5)
    @text_lines        = (text_lines.is_a?(String) ? text_lines.split("\n") : text_lines).flatten
    @text_size         = text_size
    @frame_alignment   = frame_alignment
    @frame_alignment_v = frame_alignment_v
    @text_alignment    = text_alignment
    @offset            = offset

    primitives
  end

  def primitives
    return @primitives if @primitives

    @primitives = []

    frame_w, line_h = @text_lines.map { |text| gtk.calcstringbox(text, @text_size) }.max_by(&:first)
    frame_w += @offset*2
    line_h += @offset
    frame_h = @offset + @text_lines.size*line_h

    @frame = { w: frame_w, h: frame_h, a: 128 }

    @frame.x =
      case @frame_alignment
      when Numeric then @frame_alignment
      when :center then geometry.center_inside_rect_x(@frame, grid).x
      when :left   then grid.left.shift_right(@offset)
      when :right  then grid.right.shift_left(@offset + frame_w)
      end

    @frame.y =
      case @frame_alignment_v
      when Numeric then @frame_alignment_v
      when :center then geometry.center_inside_rect_y(@frame, grid).y
      when :top    then grid.top.shift_down(@offset + frame_h)
      when :bottom then grid.bottom.shift_up(@offset)
      end

    @primitives << RDDR::Frame.new(@frame, background_color: :black).primitives

    @primitives << @text_lines.map.with_index do |text, index|
      x =
        case @text_alignment
        when :left   then @frame.x.shift_right(@offset)
        when :center then @frame.x + 0.5*@frame.w
        when :right  then (@frame.x + @frame.w).shift_left(@offset)
        end

      {
        x: x,
        y: (@frame.y + @frame.h).shift_down(@offset + line_h*index),
        text: text,
        size_enum: @text_size,
        alignment_enum: %i[left center right].index(@text_alignment),
        r: 255, g: 255, b: 255
      }.label!
    end

    @primitives
  end
end
