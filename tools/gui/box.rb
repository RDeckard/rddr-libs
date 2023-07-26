class RDDR::Box < RDDR::GTKObject
  include RDDR::Spriteable

  DEFAULT_COLOR = { r: 0, g: 0, b: 0, a: 255 }.freeze

  attr_reader :rect, :border_thickness, :background_color, :border_color, :sprite_path, :angle, :invisible

  def initialize(rect, border_thickness: nil, background_color: nil, border_color: nil, sprite_path: nil, angle: 0, invisible: nil)
    rect = rect.to_hash if rect.is_a?(Array)
    @rect = rect.dup

    @border_thickness = border_thickness || 1
    @background_color = background_color || %i[classic white]
    @border_color     = border_color     || %i[classic black]

    if @background_color.is_a?(Hash)
      @background_color = DEFAULT_COLOR.merge(@background_color)
    else
      @background_color = [:classic, @background_color] unless @background_color.is_a?(Array)
      @background_color = RDDR::Colors::SETS.dig(*@background_color)
    end

    if @border_color.is_a?(Hash)
      @border_color = DEFAULT_COLOR.merge(@border_color)
    else
      @border_color = [:classic, @border_color] unless @border_color.is_a?(Array)
      @border_color = RDDR::Colors::SETS.dig(*@border_color)
    end

    @sprite_path = sprite_path
    @angle       = angle

    @invisible = invisible || false
  end

  def primitives
    @primitives ||=
      if @invisible
        []
      elsif @sprite_path
        Array(self)
      else
        case @border_thickness
        when 0
          [@rect.solid!(@background_color)]
        when 1
          [@rect.merge(@background_color).solid!, @rect.border!(@border_color)]
        else
          [
            @rect.solid!(@background_color),
            { x: @rect.left,  y: @rect.bottom, w: @border_thickness,  h: @rect.h           }.solid!(@border_color),
            { x: @rect.left,  y: @rect.top,    w: @rect.w,           h: -@border_thickness }.solid!(@border_color),
            { x: @rect.right, y: @rect.top,    w: -@border_thickness, h: -@rect.h          }.solid!(@border_color),
            { x: @rect.right, y: @rect.bottom, w: -@rect.w,          h: @border_thickness  }.solid!(@border_color)
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

  def excluded_attributes_from_serialization
    return %i[primitives] if @sprite_path

    super
  end

  def reset_primitives!
    @primitives = nil
  end
end
