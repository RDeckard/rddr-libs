class Frame < RDDR::GTKObject
  attr_reader :rect

  def initialize(rect, frame_thickness: 1, background_color: %i[classic white], border_color: %i[classic black])
    @rect = rect.dup
    @frame_thickness = frame_thickness

    background_color  = [:classic, background_color] unless background_color.is_a?(Array)
    @background_color = RDDR::Colors::SETS.dig(*background_color)

    border_color  = [:classic, border_color] unless border_color.is_a?(Array)
    @border_color = RDDR::Colors::SETS.dig(*border_color)
  end

  def primitives
    @primitives ||=
      case @frame_thickness
      when 0
        [@rect.solid!(@background_color)]
      when 1
        [@rect.merge(@background_color).solid!, @rect.border!(@border_color)]
      else
        [
          @rect.solid!(@background_color),
          { x: @rect.left,  y: @rect.bottom, w: @frame_thickness,  h: @rect.h           }.solid!(@border_color),
          { x: @rect.left,  y: @rect.top,    w: @rect.w,           h: -@frame_thickness }.solid!(@border_color),
          { x: @rect.right, y: @rect.top,    w: -@frame_thickness, h: -@rect.h          }.solid!(@border_color),
          { x: @rect.right, y: @rect.bottom, w: -@rect.w,          h: @frame_thickness  }.solid!(@border_color)
        ]
      end
  end
end
