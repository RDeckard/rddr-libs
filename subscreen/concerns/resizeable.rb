class RDDR::Subscreen < RDDR::GTKObject
  module Resizeable
    EASE_DURATION = 30
    EASE_TYPE = %i[flip quint flip].freeze

    def start_resizing!(targeted_rect)
      @start_rect = rect.dup
      @targeted_rect = targeted_rect.dup

      @start_time = state.tick_count
    end

    def easing_resize!
      return unless @targeted_rect

      current_progress = args.easing.ease @start_time,
                                          state.tick_count,
                                          EASE_DURATION,
                                          EASE_TYPE

      if current_progress >= 1
        self.rect = @targeted_rect

        @start_time = @start_rect = @targeted_rect = nil
      else
        self.rect =
          {
            x: @start_rect.x + (@targeted_rect.x - @start_rect.x) * current_progress,
            y: @start_rect.y + (@targeted_rect.y - @start_rect.y) * current_progress,
            w: @start_rect.w + (@targeted_rect.w - @start_rect.w) * current_progress,
            h: @start_rect.h + (@targeted_rect.h - @start_rect.h) * current_progress,
          }
      end
    end
  end
end
