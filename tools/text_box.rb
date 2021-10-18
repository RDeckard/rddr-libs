class RDDR::TextBox < RDDR::GTKObject
  attr_reader :box, :text_lines

  def initialize(text_lines, text_size: 0, box_alignment: :center, box_alignment_v: :center, text_alignment: :left, offset: 5)
    @text_lines      = text_lines.flatten
    @text_size       = text_size
    @box_alignment   = box_alignment
    @box_alignment_v = box_alignment_v
    @text_alignment  = text_alignment
    @offset          = offset

    primitives
  end

  def primitives
    return @primitives if @primitives

    @primitives = []

    box_w, line_h = @text_lines.map { |text| gtk.calcstringbox(text, @text_size) }.max_by(&:first)
    box_w += @offset*2
    line_h += @offset
    box_h = @offset + @text_lines.size*line_h

    @box = { w: box_w, h: box_h, a: 128 }.solid!

    @box.x =
      case @box_alignment
      when Numeric then @box_alignment
      when :center then geometry.center_inside_rect_x(@box, grid).x
      when :left   then grid.left.shift_right(@offset)
      when :right  then grid.right.shift_left(@offset + box_w)
      end

    @box.y =
      case @box_alignment_v
      when Numeric then @box_alignment_v
      when :center then geometry.center_inside_rect_y(@box, grid).y
      when :top    then grid.top.shift_down(@offset + box_h)
      when :bottom then grid.bottom.shift_up(@offset)
      end

    @primitives << @box

    @primitives << @text_lines.map.with_index do |text, index|
      x =
        case @text_alignment
        when :left   then @box.x.shift_right(@offset)
        when :center then @box.x + 0.5*@box.w
        when :right  then (@box.x + @box.w).shift_left(@offset)
        end

      {
        x: x,
        y: (@box.y + @box.h).shift_down(@offset + line_h*index),
        text: text,
        size_enum: @text_size,
        alignment_enum: %i[left center right].index(@text_alignment),
        r: 255, g: 255, b: 255
      }.label!
    end

    @primitives
  end
end
