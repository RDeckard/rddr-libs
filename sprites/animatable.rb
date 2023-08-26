module RDDR::Animatable
  SPRITE_SHEET = nil # # optional, fallback to #sprite_sheet (sprite can't be animatable without a sprite sheet)
  DIRECTION_OF_COLLECTIONS = :horizontal # :horizontal, :vertical, :horizontal_then_vertical, :vertical_then_horizontal
  FRAMES_COLLECTIONS = { default: 0 }.freeze # Only use with :horizontal and :vertical directions: indexes of the row/column of each collection
  FRAMES_PER_COLLECTION = { default: 1 }.freeze # Only use with :horizontal and :vertical directions: indexes of the row/column of each collection
  TICKS_PER_FRAME = 6
  ANIMATION_DIRECTION = :forward # :forward, :reverse, :ping_pong
  RANDOM_FIRST_FRAME = false # pick a random first frame from the collection
  TILES_ORIGIN_X = 0
  TILES_ORIGIN_Y = 0

  CYCLE = true

  attr_accessor :sprite_sheet, :animation_direction, :random_first_frame, :cycle
  attr_reader :frames_collection_name, :frames_per_collection, :ticks_per_frame

  def initialize(
        sprite_sheet: self.class::SPRITE_SHEET,
        frames_collection_name: :default,
        ticks_per_frame: self.class::TICKS_PER_FRAME,
        animation_direction: self.class::ANIMATION_DIRECTION,
        random_first_frame: self.class::RANDOM_FIRST_FRAME,
        cycle: self.class::CYCLE
      )
    @sprite_sheet = sprite_sheet

    set_frames_collection(frames_collection_name)

    @ticks_per_frame = ticks_per_frame
    @animation_direction = animation_direction
    @random_first_frame = random_first_frame
    @cycle = cycle

    start_animation!
  end

  def ticks_per_frame=(value)
    @ticks_per_frame = value

    @tile_index_throttle = nil
    @tile_index = nil
    @tile_index_direction = nil
  end

  def animatable?
    sprite_sheet.present?
  end

  def set_frames_collection(frames_collection_name)
    @frames_collection_name = frames_collection_name unless frames_collection_name.nil?

    @frames_per_collection = if self.class::FRAMES_PER_COLLECTION.is_a?(Hash)
                               self.class::FRAMES_PER_COLLECTION.fetch(@frames_collection_name)
                             else
                               self.class::FRAMES_PER_COLLECTION
                             end

    @frames_collection_index = self.class::FRAMES_COLLECTIONS.fetch(@frames_collection_name)
  end

  def start_animation!(
        frames_collection_name = nil, ticks_per_frame: nil, random_first_frame: nil,
        flip_horizontally: nil, flip_vertically: nil
      )
    set_frames_collection(frames_collection_name)

    self.ticks_per_frame = ticks_per_frame unless ticks_per_frame.nil?
    @random_first_frame = random_first_frame unless random_first_frame.nil?

    set_flips(flip_horizontally, flip_vertically)

    random_offset = @random_first_frame ? rand(0..frames_per_collection - 1) * @ticks_per_frame : 0
    @animation_started_at = state.tick_count - random_offset
  end

  def cycling_animated_params
    if frames_per_collection > 1
      tile_index = tile_index()

      case self.class::DIRECTION_OF_COLLECTIONS
      when :horizontal_then_vertical
        tile_index += @frames_collection_index
        tile_x_index = tile_index % self.class::FRAMES_PER_ROW
        tile_y_index = (tile_index / self.class::FRAMES_PER_ROW).floor
      when :vertical_then_horizontal
        tile_index += @frames_collection_index
        tile_x_index = (tile_index / self.class::FRAMES_PER_ROW).floor
        tile_y_index = tile_index % self.class::FRAMES_PER_ROW
      else
        tile_x_index = self.class::DIRECTION_OF_COLLECTIONS == :vertical   ? @frames_collection_index : tile_index
        tile_y_index = self.class::DIRECTION_OF_COLLECTIONS == :horizontal ? @frames_collection_index : tile_index
      end
    else
      tile_x_index = tile_y_index = 0
    end

    {
      path: sprite_sheet,
      tile_x: self.class::TILES_ORIGIN_X + (tile_x_index * sprite_width),
      tile_y: self.class::TILES_ORIGIN_Y + (tile_y_index * sprite_height),
      tile_w: sprite_width, tile_h: sprite_height,
    }
  end

  def tile_index
    if @animation_direction == :ping_pong
      @tile_index_throttle ||= RDDR::Timer.throttle(ticks_per_frame / 60)
      @tile_index ||= @animation_started_at.frame_index(frames_per_collection, ticks_per_frame, @cycle)
      @tile_index_direction ||= :forward
      return @tile_index unless @tile_index_throttle.call

      case @tile_index_direction
      when :forward
        @tile_index += 1
        @tile_index_direction = :reverse if @tile_index == frames_per_collection - 1
      when :reverse
        @tile_index -= 1
        @tile_index_direction = :forward if @tile_index.zero?
      end

      @tile_index
    else
      @animation_started_at.frame_index(frames_per_collection, ticks_per_frame, @cycle).then do |i|
        case @animation_direction
        when :forward then i
        when :reverse then frames_per_collection - 1 - i
        end
      end
    end
  end

  def animation_finished?
    return false if @cycle

    # we want to memoize only the true value, so we can use ||= on this boolean
    @animation_finished ||= !tile_index
  end

  def animation_alived?
    !animation_finished?
  end
end
