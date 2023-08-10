module RDDR::Animatable
  SPRITE_SHEET = nil # # optional, fallback to #sprite_sheet (sprite can't be animatable without a sprite sheet)
  FRAMES_PER_COLLECTION = 1
  DIRECTION_OF_COLLECTIONS = :horizontal # :horizontal, :vertical, :horizontal_then_vertical, :vertical_then_horizontal
  FRAMES_COLLECTIONS = { default: 0 }.freeze # Only use with :horizontal and :vertical directions: indexes of the row/column of each collection
  TICKS_PER_FRAME = 6
  RANDOM_FIRST_FRAME = false # pick a random first frame from the collection
  TILES_ORIGIN_X = 0
  TILES_ORIGIN_Y = 0

  CYCLE = true

  attr_accessor :sprite_sheet, :frames_collection, :ticks_per_frame, :random_first_frame, :cycle

  def initialize(
        sprite_sheet: self.class::SPRITE_SHEET,
        frames_collection: :default,
        ticks_per_frame: self.class::TICKS_PER_FRAME,
        random_first_frame: self.class::RANDOM_FIRST_FRAME,
        cycle: self.class::CYCLE
      )
    @sprite_sheet = sprite_sheet

    set_frames_collection(frames_collection)

    @ticks_per_frame = ticks_per_frame
    @random_first_frame = random_first_frame
    @cycle = cycle

    start_animation!
  end

  def animatable?
    sprite_sheet.present?
  end

  def set_frames_collection(frames_collection)
    self.frames_collection = frames_collection unless frames_collection.nil?

    @frames_collection_index = case self.frames_collection
                               when Symbol  then self.class::FRAMES_COLLECTIONS[self.frames_collection]
                               when Numeric then self.frames_collection
                               end
  end

  def start_animation!(
        frames_collection = nil, ticks_per_frame: nil, random_first_frame: nil,
        flip_horizontally: nil, flip_vertically: nil
      )
    set_frames_collection(frames_collection)

    self.ticks_per_frame = ticks_per_frame unless ticks_per_frame.nil?
    self.random_first_frame = random_first_frame unless random_first_frame.nil?

    set_flips(flip_horizontally, flip_vertically)

    random_offset = self.random_first_frame ? rand(0..self.class::FRAMES_PER_COLLECTION - 1) * self.ticks_per_frame : 0
    @animation_started_at = state.tick_count - random_offset
  end

  def cycling_animated_params
    if self.class::FRAMES_PER_COLLECTION > 1
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
    @animation_started_at.frame_index(self.class::FRAMES_PER_COLLECTION, ticks_per_frame, @cycle)
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
