class Menu < GTKObject
  attr_reader :updated_labels

  def initialize(prompts:, x: grid.w / 2, y: grid.h / 2, mode: :sequential)
    @prompts = prompts
    @x = x
    @y = y
    @mode = mode
  end

  def call
    case @mode
    when :flat       then flat_tick
    when :sequential then sequential_tick
    end
  end

  def flat_tick
  end

  def sequential_tick
    @current_prompt ||= next_prompt

    if @current_prompt
      result = @current_prompt.call

      @updated_labels = @current_prompt.updated_labels

      if result
        @current_prompt = next_prompt
      elsif inputs.keyboard.key_down.escape
        previous_prompt&.then do |prompt|
          @current_prompt = prompt
        end || :done
      end
    else
      :done
    end
  end

  def next_prompt
    @current_prompt_index ||= -1

    @prompts[@current_prompt_index += 1]&.place!(@x, @y)
  end

  def previous_prompt
    return if @current_prompt_index == 0

    @prompts[@current_prompt_index -= 1].place!(@x, @y)
  end
end
