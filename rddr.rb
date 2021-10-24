module RDDR
  NEW_LINE = ["".freeze].freeze
  SPACE    = " ".freeze

  extend self

  def wrapped_lines(text_lines, max_chars_by_line, keep_last_spaces: false)
    Array(text_lines).flat_map do |text_line|
      $gtk.args.string.wrapped_lines(text_line, max_chars_by_line).
        tap do |wrapped_text_lines|
          next unless keep_last_spaces

          wrapped_text_lines.last << SPACE while text_line.delete_suffix!(" ")
        end.presence || NEW_LINE
    end
  end
end
