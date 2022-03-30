class Frame < RDDR::GTKObject
  include RDDR::Spriteable

  attr_reader :rect, :sprite_path, :angle

  def initialize(rect, frame_thickness: nil, background_color: nil, border_color: nil, sprite_path: nil, angle: 0)
    @rect = rect.dup

    @frame_thickness  = frame_thickness  || 1
    @background_color = background_color || %i[classic white]
    @border_color     = border_color     || %i[classic black]

    @background_color = [:classic, @background_color] unless @background_color.is_a?(Array)
    @background_color = RDDR::Colors::SETS.dig(*@background_color)

    @border_color = [:classic, @border_color] unless @border_color.is_a?(Array)
    @border_color = RDDR::Colors::SETS.dig(*@border_color)

    @sprite_path = sprite_path
    @angle       = angle
  end

  def primitives
    @primitives ||=
      if @sprite_path
        self
      else
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

  def draw_parameters
    {
      x: @rect.x, y: @rect.y,
      w: @rect.w, h: @rect.h,
      path: @sprite_path, angle: @angle,
      angle_anchor_x: 0.5, angle_anchor_y: 0.5
    }
  end
end
