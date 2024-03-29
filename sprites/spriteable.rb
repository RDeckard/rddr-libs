module RDDR::Spriteable
  include RDDR::Animatable

  DEFAULT_SPRITE = "pixel"

  SPRITE_PATH = nil # optional, fallback to #sprite_path then DEFAULT_SPRITE
  SPRITE_SCALE = 1.0 # optional, fallback to #sprite_scale then 1.0. Can also be a Hash with :x and :y keys.
  SPRITE_WIDTH = nil # optional, fallback to #sprite_width then SPRITE_SIZE
  SPRITE_HEIGHT = nil # optional, fallback to #sprite_height then SPRITE_SIZE

  SPRITE_SCALES = nil # optional, useful to compute the #mass
  FIXED_MASS = 1 # optional, see #mass
  MASS_MIN = 0 # optional, see #mass
  MASS_MAX = 1 # optional, see #mass

  ANCHOR = { x: 0, y: 0 }.freeze
  ANGLE_ANCHOR = { x: 0.5, y: 0.5 }.freeze

  FLIP_HORIZONTALLY = false
  FLIP_VERTICALLY = false

  VISIBLE = true
  ALPHA = 255

  attr_accessor :x, :y, :w, :h, :sprite_width, :sprite_height, :flip_horizontally, :flip_vertically, :alpha
  attr_reader :angle, :sprite_scale
  attr_writer :sprite_path, :visible

  def initialize(
    angle: 0,
    sprite_path: self.class::SPRITE_PATH,
    sprite_width: self.class::SPRITE_WIDTH || self.class::SPRITE_SIZE,
    sprite_height: self.class::SPRITE_HEIGHT || self.class::SPRITE_SIZE,
    sprite_scale: self.class::SPRITE_SCALE,
    flip_horizontally: self.class::FLIP_HORIZONTALLY,
    flip_vertically: self.class::FLIP_VERTICALLY,
    visible: self.class::VISIBLE,
    alpha: self.class::ALPHA,
    **kwargs
  )
    @angle = angle

    @sprite_path = sprite_path
    @sprite_width = sprite_width
    @sprite_height = sprite_height
    self.sprite_scale = sprite_scale

    set_flips(flip_horizontally, flip_vertically)

    @visible = visible
    @alpha = alpha

    super(**kwargs)
  end

  def set_width_and_height
    @w = @sprite_width * @sprite_scale.x
    @h = @sprite_height * @sprite_scale.y
  end

  def set_flips(flip_horizontally, flip_vertically)
    @flip_h = @flip_horizontally = flip_horizontally unless flip_horizontally.nil?
    @flip_v = @flip_vertically = flip_vertically unless flip_vertically.nil?

    @flip_h = rand(2).zero? if @flip_horizontally == :random
    @flip_v = rand(2).zero? if @flip_vertically == :random
  end

  def primitive_marker
    :sprite
  end

  def angle=(value)
    @angle = value.mod(360)
  end

  def anchor
    self.class::ANCHOR
  end

  def angle_anchor
    self.class::ANGLE_ANCHOR
  end

  def sprite_scale=(value)
    @sprite_scale = if value.is_a?(Hash)
                      value.merge(avg: (value.x + value.y) / 2)
                    else
                      { x: value, y: value, avg: value }
                    end

    set_width_and_height unless @sprite_width.nil? || @sprite_height.nil?
    @mass = nil
    mass # trigger calculation
  end

  # from min to max, proportional to sprite_scale relative to SPRITE_SCALES
  def mass
    return self.class::FIXED_MASS if self.class::SPRITE_SCALES.nil?

    @mass ||=
      begin
        min_scale, max_scale = self.class::SPRITE_SCALES.minmax
        ratio = (@sprite_scale.avg - min_scale) / (max_scale - min_scale)

        (
          self.class::MASS_MIN * (1 - ratio) + ratio * self.class::MASS_MAX
        ).clamp(self.class::MASS_MIN, self.class::MASS_MAX).round(2)
      end
  end

  # Can be overriden by subclasses
  def sprite_path
    @sprite_path ||= DEFAULT_SPRITE
  end

  def visible!
    @visible = true
  end

  def invisible!
    @visible = false
  end

  def visible?
    @visible
  end

  def invisible?
    !visible?
  end

  def rect
    {
      x: x, y: y, w: sprite_width, h: sprite_height,
      anchor_x: anchor.x, anchor_y: anchor.y,
    }.scale_rect_extended(
      percentage_x: sprite_scale.x, percentage_y: sprite_scale.y,
      anchor_x: 0, anchor_y: 0,
    )
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
        { x: shape_rect.x,                y: shape_rect.y },
        { x: shape_rect.x + shape_rect.w, y: shape_rect.y },
        { x: shape_rect.x + shape_rect.w, y: shape_rect.y + shape_rect.h },
        { x: shape_rect.x,                y: shape_rect.y + shape_rect.h }
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
  def shape_lines(color: nil)
    shape_corners = shape_corners() # temporary memöization

    [
      shape_corners[0].line!(x2: shape_corners[1].x, y2: shape_corners[1].y),
      shape_corners[1].line!(x2: shape_corners[2].x, y2: shape_corners[2].y),
      shape_corners[2].line!(x2: shape_corners[3].x, y2: shape_corners[3].y),
      shape_corners[3].line!(x2: shape_corners[0].x, y2: shape_corners[0].y)
    ].tap do |shape_lines|
      next unless color

      shape_lines.each { _1.merge!(RDDR.color(color)) }
    end
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

  # non relative rotation center (angle_anchor.x and angle_anchor.y are relative)
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
    return if invisible? || (animatable? && animation_finished?)

    params = draw_parameters

    params.merge!(cycling_animated_params) if animatable?

    ffi_draw.draw_sprite_5(
      params[:x], params[:y],
      params[:w], params[:h],
      params[:path] || sprite_path, params[:angle] || angle,
      params[:alpha] || alpha, params[:r], params[:g], params[:b],
      params[:tile_x], params[:tile_y], params[:tile_w], params[:tile_h],
      params[:flip_horizontally] || @flip_h, params[:flip_vertically] || @flip_v,
      params[:angle_anchor_x] || angle_anchor.x, params[:angle_anchor_y] || angle_anchor.y,
      params[:source_x], params[:source_y], params[:source_w], params[:source_h],
      params[:blendmode_enum],
      params[:anchor_x] || anchor.x, params[:anchor_y] || anchor.y,
    )
  end
end
