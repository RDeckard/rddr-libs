module RDDR
  NEW_LINE = ["".freeze].freeze
  SPACE    = " ".freeze

  extend self

  def wrapped_lines(text_lines, max_chars_by_line, rstrip: true)
    Array(text_lines).flat_map do |text_line|
      $gtk.args.string.wrapped_lines(text_line, max_chars_by_line).
        tap do |wrapped_text_lines|
          next unless rstrip

          wrapped_text_lines.last << SPACE while text_line.delete_suffix!(" ")
        end.presence || NEW_LINE
    end
  end

  def color(*args)
    args.flatten!(1)

    args = [:classic, *args] if args.one?
    RDDR::Colors::SETS.dig(*args).dup
  end

  def animated_colors(first_color, second_color, interval: 0.2)
    interval_in_ticks = interval * 60

    first_color = [:classic, first_color] unless first_color.is_a?(Array)
    second_color = [:classic, second_color] unless second_color.is_a?(Array)

    if ($gtk.args.state.tick_count / interval_in_ticks).floor.mod(2).zero?
      RDDR::Colors::SETS.dig(*first_color).dup
    else
      RDDR::Colors::SETS.dig(*second_color).dup
    end
  end

  def debug_mode?
    $gtk.args.state.rddr_debug_mode
  end

  def start_debug_mode!
    $gtk.args.state.rddr_debug_mode = true
  end

  def stop_debug_mode!
    $gtk.args.state.rddr_debug_mode = false
  end

  def toggle_debug_mode!
    $gtk.args.state.rddr_debug_mode = !$gtk.args.state.rddr_debug_mode
  end
end
