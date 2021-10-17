class Prompt < GTKObject
  CURSOR_BLINKS_PER_SEC = 2
  BACKSPACES_PER_SEC    = 10

  attr_reader :updated_labels

  def initialize(title: "", description: "", default_value: "", cursor: "_", size: 2, alignment: :center, validation: proc { true }, continuous_action: nil)
    @title             = title
    @description_lines = description.split("\n")
    @value             = default_value
    @cursor            = cursor

    @size_enum      = size
    @alignment_enum = %i[left center right].index(alignment)

    _, @line_height = gtk.calcstringbox("text", @size_enum)

    @validation        = validation
    @continuous_action = continuous_action
  end

  def call
    @updated_labels = []

    @x += grid.right if @x.negative?
    @y += grid.top   if @y.negative?

    backspace_handler
    @value << inputs.text.join

    cursor_blink = cursor_blink?

    if @value.size != @last_value_size || cursor_blink
      @cursor = @cursor == " " ? "_" : " " if cursor_blink

      run_continuous_action
        @updated_labels << [
          {
            x: grid.left.shift_right(@x), y: grid.bottom.shift_up(@y),
            text: "#{@title} #{@value}#{@cursor}",
            size_enum: @size_enum,
            alignment_enum: @alignment_enum
          },
          @description_lines.map.with_index do |description_line, line_number|
            line_number += 1
            {
              x: grid.left.shift_right(@x), y: grid.bottom.shift_up(@y + @line_height * (@description_lines.count - line_number + 1)),
              text: "#{description_line}",
              size_enum: @size_enum,
              alignment_enum: @alignment_enum,
              r: 128, g: 128, b: 128
            }
          end
        ]
    end

    @last_value_size = @value.size

    run_validation if inputs.keyboard.key_down.enter || inputs.mouse.click
  end

  def place!(x, y)
    @x = x
    @y = y

    self
  end

  private

  def run_validation
    return true if @validation.call(@value)

    @value = ""
    false
  end

  def run_continuous_action
    return unless @continuous_action

    valid, text = @continuous_action.call(@value)

    @value = @value[0..-2] unless valid

    return if text.to_s.empty?

    @updated_labels << {
      x: grid.left.shift_right(@x), y: grid.bottom.shift_up(@y - @line_height),
      text: text,
      size_enum: 1,
      alignment_enum: 1,
    }.label!.tap do |label|
      label.merge!(r: 255, g: 0, b: 0) unless valid
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
