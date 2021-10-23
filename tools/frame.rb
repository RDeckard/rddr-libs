class Frame
  def initialize(frame_rect, frame_thickness: 1, background_color: %i[classic white], border_color: %i[classic black])
    @frame_rect       = frame_rect.dup
    @frame_thickness  = frame_thickness

    background_color  = [:classic, background_color] unless background_color.is_a?(Array)
    @background_color = RDDR::Colors::SETS.dig(*background_color)

    border_color  = [:classic, border_color] unless border_color.is_a?(Array)
    @border_color = RDDR::Colors::SETS.dig(*border_color)
  end

  def primitives
    @primitives ||=
      case @frame_thickness
      when 0
        [@frame_rect.solid!(@background_color)]
      when 1
        [@frame_rect.merge(@background_color).solid!, @frame_rect.border!(@border_color)]
      else
        [
          @frame_rect.solid!(@background_color),
          { x: @frame_rect.left,  y: @frame_rect.bottom, w: @frame_thickness,  h: @frame_rect.h     }.solid!(@border_color),
          { x: @frame_rect.left,  y: @frame_rect.top,    w: @frame_rect.w,     h: -@frame_thickness }.solid!(@border_color),
          { x: @frame_rect.right, y: @frame_rect.top,    w: -@frame_thickness, h: -@frame_rect.h    }.solid!(@border_color),
          { x: @frame_rect.right, y: @frame_rect.bottom, w: -@frame_rect.w,    h: @frame_thickness  }.solid!(@border_color)
        ]
      end
  end
end
