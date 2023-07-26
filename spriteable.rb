module RDDR::Spriteable
  SPRITE_SHEET = "pixel"

  SPRITE_SCALE = 1.0
  FRAMES_PER_COLLECTION = 1
  TICKS_PER_FRAME = 6
  TILES_ORIGIN_X = 0
  TILES_ORIGIN_Y = 0
  FRAMES_COLLECTIONS = { default: 0 }.freeze

  def primitive_marker
    :sprite
  end

  def anchor_x
    0
  end

  def anchor_y
    0
  end

  def rect
    { x: x, y: y, w: w, h: h }.scale_rect(self.class::SPRITE_SCALE, anchor_x, anchor_y)
  end

  # Warning: this matches well only with square rotated sprites (even with after_rotation == true)
  def shape_rect(after_rotation: false)
    if after_rotation && (90 - angle % 180).abs < 45 # closer to the "left" or "right" orientations (angle of 90 or 270 degrees)
      rotation_offset = rotation_offset()

      rect.merge!(x: x.shift_left(rotation_offset), y: y.shift_up(rotation_offset))
    else # closer to the "up" or "down" orientations (angle of 0 or 180 degrees)
      rect
    end
  end

  def rotation_offset
    (w - h).abs / 2
  end

  # Returns the 4 corners of the sprite as points (taking in account any rotation)
  def shape_corners
    if (angle % 90).round(3).zero?
      # Square rotation cases optimization
      shape_rect = shape_rect(after_rotation: true)

      [
        { x: shape_rect.x,          y: shape_rect.y },
        { x: shape_rect.x + shape_rect.w, y: shape_rect.y },
        { x: shape_rect.x + shape_rect.w, y: shape_rect.y + shape_rect.h },
        { x: shape_rect.x,          y: shape_rect.y + shape_rect.h }
      ]
    else
      rotation_center = rotation_center() # temporary memoization

      [
        { x: x,     y: y },
        { x: x + w, y: y },
        { x: x + w, y: y + h },
        { x: x,     y: y + h }
      ].map { Geometry.rotate_point(_1, angle, rotation_center) }
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
      point.inside_rect?(shape_rect(after_rotation: true))
    else
      # Interesting point: this clause wouldn't work with square rotation cases! (ray_tests :left or :right is arbitrary with straight lines)
      shape_lines.
        map { |shape_line| Geometry.ray_test(point, shape_line) }.
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

  def start_animation!(frames_collection = :default, random: false)
    random_offset = random ? rand(0..self.class::FRAMES_PER_COLLECTION - 1) * self.class::TICKS_PER_FRAME : 0

    @animation_started_at = state.tick_count - random_offset
    @frames_collection = self.class::FRAMES_COLLECTIONS[frames_collection]
  end

  def cycling_animated_params
    if self.class::FRAMES_PER_COLLECTION > 1
      tile_index = @animation_started_at.frame_index(self.class::FRAMES_PER_COLLECTION, self.class::TICKS_PER_FRAME, true)
      if self.class::DIRECTION_OF_COLLECTIONS == :horizontal_then_vertical
        tile_x_index = tile_index % self.class::FRAMES_PER_ROW
        tile_y_index = (tile_index / self.class::FRAMES_PER_ROW).floor
      else
        tile_x_index = self.class::DIRECTION_OF_COLLECTIONS == :vertical   ? @frames_collection : tile_index
        tile_y_index = self.class::DIRECTION_OF_COLLECTIONS == :horizontal ? @frames_collection : tile_index
      end
    else
      tile_x_index = tile_y_index = 0
    end

    {
      path: self.class::SPRITE_SHEET,
      tile_x: self.class::TILES_ORIGIN_X + (tile_x_index * w),
      tile_y: self.class::TILES_ORIGIN_Y + (tile_y_index * h),
      tile_w: w, tile_h: h,
    }
  end

  def draw_override(ffi_draw)
    params = draw_parameters

    if params[:path].blank? && self.class::SPRITE_SHEET != "pixel"
      params =
        params
          .merge!(cycling_animated_params)
          .scale_rect(self.class::SPRITE_SCALE, anchor_x, anchor_y)
    end

    ffi_draw.draw_sprite_5(
      params[:x], params[:y],
      params[:w], params[:h],
      params[:path] || SPRITE_SHEET, params[:angle],
      params[:alpha], params[:r], params[:g], params[:b],
      params[:tile_x], params[:tile_y], params[:tile_w], params[:tile_h],
      params[:flip_horizontally], params[:flip_vertically],
      params[:angle_anchor_x], params[:angle_anchor_y],
      params[:source_x], params[:source_y], params[:source_w], params[:source_h],
      params[:blendmode_enum],
      params[:anchor_x], params[:anchor_y],
    )
  end
end
