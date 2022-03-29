module RDDR::Spriteable
  DEFAULT_SPRITE = "pixel"

  def primitive_marker
    :sprite
  end

  # Warning: this matches well only with square rotated sprites (even with after_rotation == true)
  def rect(after_rotation: false)
    if after_rotation && (90 - angle % 180).abs < 45 # closer to the "left" or "right" orientations (angle of 90 or 270 degrees)
      rotation_offset = rotation_offset()

      { x: x.shift_left(rotation_offset), y: y.shift_up(rotation_offset), w: h, h: w }
    else # closer to the "up" or "down" orientations (angle of 0 or 180 degrees)
      { x: x, y: y, w: w, h: h }
    end
  end

  def rotation_offset
    (w - h).abs / 2
  end

  # Returns the 4 corners of the sprite as points (taking in account any rotation)
  def shape_corners
    if (angle % 90).round(3).zero?
      # Square rotation cases optimization
      rect = rect(after_rotation: true)

      [
        { x: rect.x,          y: rect.y },
        { x: rect.x + rect.w, y: rect.y },
        { x: rect.x + rect.w, y: rect.y + rect.h },
        { x: rect.x,          y: rect.y + rect.h }
      ]
    else
      rotation_center = rotation_center() # temporary memoization

      [
        { x: x,     y: y },
        { x: x + w, y: y },
        { x: x + w, y: y + h },
        { x: x,     y: y + h }
      ].map { geometry.rotate_point(_1, angle, rotation_center) }
    end
  end

  # Returns 4 lines as a box containing the sprite (taking in account any rotation)
  def shape_lines
    shape_corners = shape_corners() # temporary memöization

    [
      shape_corners[0].merge(x2: shape_corners[1].x, y2: shape_corners[1].y),
      shape_corners[1].merge(x2: shape_corners[2].x, y2: shape_corners[2].y),
      shape_corners[2].merge(x2: shape_corners[3].x, y2: shape_corners[3].y),
      shape_corners[3].merge(x2: shape_corners[0].x, y2: shape_corners[0].y)
    ]
  end

  # Works with any rotation (unlike GTK #inside_rect? methods)
  def contains_point?(point)
    if (angle % 90).round(3).zero?
      # Square rotation cases optimization
      point.inside_rect?(rect(after_rotation: true))
    else
      # Interesting point: this clause wouldn't work with square rotation cases! (ray_tests :left or :right is arbitrary with straight lines)
      shape_lines.
        map { |shape_line| geometry.ray_test(point, shape_line) }.
        then do |ray_tests|
          ray_tests[0] == ray_tests[2] && ray_tests[1] == ray_tests[3] || !!ray_tests.index(:on)
        end
    end
  rescue => e
    return if e.message[":inside_rect? failed"]

    raise e
  end

  # non relative rotation center (angle_anchor_x and angle_anchor_y are relative)
  def rotation_center
    { x: x + w * angle_anchor.x, y: y + h * angle_anchor.y }
  end

  def merge!(**attributes)
    attributes.each do |attribute, value|
      send("#{attribute}=", value)
    end

    self
  end

  def draw_override(ffi_draw)
    params = draw_parameters

    ffi_draw.draw_sprite_4(
      params[:x], params[:y],                                                     # x, y,
      params[:w], params[:h],                                                     # w, h,
      params[:path] || DEFAULT_SPRITE, params[:angle],                            # path, angle,
      params[:alpha], params[:r], params[:g], params[:b],                         # alpha, red, green, blue,
      params[:tile_x], params[:tile_y], params[:tile_w], params[:tile_h],         # tile_x, tile_y, tile_w, tile_h,
      params[:flip_horizontally], params[:flip_vertically],                       # flip_horizontally, flip_vertically,
      params[:angle_anchor_x], params[:angle_anchor_y],                           # angle_anchor_x, angle_anchor_y,
      params[:source_x], params[:source_y], params[:source_w], params[:source_h], # source_x, source_y, source_w, source_h,
      params[:blendmode_enum]                                                     # blendmode_enum
    )
  end
end
