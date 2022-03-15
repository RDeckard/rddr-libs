class RDDR::Prompt < RDDR::GTKObject
  CURSOR_BLINKS_PER_SEC = 2
  BACKSPACES_PER_SEC    = 10

  attr_reader :updated_labels, :enable

  def initialize(title: "", description: "", default_value: "", size: 2, alignment: :center, validation: proc { true }, continuous_action: nil)
    @title             = title
    @description_lines = description.split("\n")
    @value             = default_value.to_s.dup
    @cursor            = "_"

    @size_enum      = size
    @alignment_enum = %i[left center right].index(alignment)

    @character_width, @line_height = gtk.calcstringbox("x", @size_enum)

    @validation        = validation
    @continuous_action = continuous_action

    enable!
  end

  def call(frame_width = grid.w)
    return unless @enable || !@render_in_disable_state

    wrap_description_lines!(frame_width)

    @updated_labels = []

    if @enable
      backspace_handler
      @value << inputs.text.join

      cursor_blink = cursor_blink?
    end

    if @value.size != @last_value_size || cursor_blink || !@enable
      if @enable
        @cursor = @cursor == " " ? "_" : " " if cursor_blink
        run_continuous_action
        @render_in_disable_state = false
      end

      unless @render_in_disable_state
        @field_lines =
          RDDR.wrapped_lines("#{@title} #{@value}", @max_chars_by_line - 1, keep_last_spaces: true)

        @updated_labels << [
          @field_lines.map.with_index do |field_line, line_number|
            line_number += 1
            field_line.concat(@cursor) if line_number == @field_lines.count

            {
              x: @x, y: @y - @line_height * (line_number - 1),
              text: field_line,
              size_enum: @size_enum,
              alignment_enum: @alignment_enum,
              r: 0, g: 0, b: 0
            }.label!
          end,
          @description_lines.map.with_index do |description_line, line_number|
            line_number += 1

            {
              x: @x, y: @y + @line_height * (@description_lines.count - line_number + 1),
              text: "#{description_line}",
              size_enum: @size_enum,
              alignment_enum: @alignment_enum,
              r: 128, g: 128, b: 128
            }.label!
          end
        ]

        unless @enable
          @updated_labels.flatten.each do |updated_label|
            updated_label.merge!(
              r: updated_label.r + (255 - updated_label.r)/2,
              g: updated_label.g + (255 - updated_label.g)/2,
              b: updated_label.b + (255 - updated_label.b)/2
            )
          end

          @render_in_disable_state = true
        end
      end
    end

    if @enable
      @last_value_size = @value.size
      run_validation if inputs.keyboard.key_down.enter || inputs.pointer.left_click
    end
  end

  def place!(x, y)
    @x = x
    @y = y

    self
  end

  def enable!
    @enable = true
  end

  def disable!
    @cursor = " "
    @enable = false
  end

  def wrap_description_lines!(frame_width)
    return if @frame_width == frame_width

    @max_chars_by_line = (frame_width / @character_width).to_i
    @description_lines = RDDR.wrapped_lines(@description_lines, @max_chars_by_line)

    @frame_width = frame_width
  end

  def run_validation
    @validation.call(@value.tap(&:strip!))
  end

  private

  def run_continuous_action
    return unless @continuous_action

    valid, text = @continuous_action.call(@value)

    @value = @value[0..-2] unless valid

    return if text.to_s.empty?

    text_lines = RDDR.wrapped_lines(text, @max_chars_by_line)

    @updated_labels <<
      text_lines.map.with_index do |text_line, line_number|
        line_number += 1
        {
          x: @x, y: @y - @line_height * (line_number + (@field_lines&.count || 1) - 1),
          text: text,
          size_enum: 1,
          alignment_enum: 1,
        }.label!.tap do |label|
          label.merge!(r: 255, g: 0, b: 0) unless valid
        end
      end
  end

  def cursor_blink?
    @ticks_per_blink ||= 60.div(CURSOR_BLINKS_PER_SEC)

    (state.tick_count % @ticks_per_blink).zero?
  end

  def backspace_handler
    @ticks_per_backspace ||= 60.div(BACKSPACES_PER_SEC)


    if inputs.keyboard.key_down.backspace
      @value = @value[0..-2]
    elsif inputs.keyboard.key_held.backspace
      delay_since_backspace_down = state.tick_count - inputs.keyboard.key_held.backspace

      if (delay_since_backspace_down % @ticks_per_backspace).zero? &&
         delay_since_backspace_down >= @ticks_per_backspace * 2
        @value = @value[0..-2]
      end
    end
  end
end
