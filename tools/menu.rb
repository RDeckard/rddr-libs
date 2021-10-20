class RDDR::Menu < RDDR::GTKObject
  def initialize(prompts:, inside_rect: nil, mode: :sequential)
    @prompts = prompts

    @inside_rect = inside_rect || grid.rect
    @mode = mode
  end

  def call
    case @mode
    when :flat       then flat_tick
    when :sequential then sequential_tick
    end
  end

  def updated_labels
    @updated_labels.flatten
  end

  def static_labels
    @static_labels.flatten
  end

  def flat_tick
    @active_prompt_index ||= 0

    @updated_labels = []
    @static_labels = []

    @prompts.each_with_index do |prompt, i|
      i == @active_prompt_index ? prompt.enable! : prompt.disable!

      center = compute_line_center(i+1, total: @prompts.count)
      prompt.place!(*center).call

      if prompt.enable
        @updated_labels << prompt.updated_labels
      else
        @static_labels << prompt.updated_labels
      end
    end

    @active_prompt_index += 1 if inputs.keyboard.key_down.down
    @active_prompt_index -= 1 if inputs.keyboard.key_down.up

    if inputs.keyboard.key_down.enter || inputs.pointer.left_click
      @active_prompt_index += 1 if @prompts[@active_prompt_index].run_validation

      return :done if @active_prompt_index >= @prompts.count && @prompts.all?(&:run_validation)
    end

    @active_prompt_index = 0 if @active_prompt_index >= @prompts.count
    @active_prompt_index = @prompts.count - 1 if @active_prompt_index < 0
  end

  def sequential_tick
    @current_prompt ||= next_prompt

    if @current_prompt
      result = @current_prompt.call

      @updated_labels = @current_prompt.updated_labels

      if result
        @current_prompt = next_prompt
      elsif inputs.keyboard.key_down.escape || inputs.pointer.right_click
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

    @prompts[@current_prompt_index += 1]&.place!(*compute_line_center)
  end

  def previous_prompt
    return if @current_prompt_index == 0

    @prompts[@current_prompt_index -= 1].place!(*compute_line_center)
  end

  def compute_line_center(n = 1, total: 1)
    [@inside_rect.x + @inside_rect.w/2, @inside_rect.top - n*@inside_rect.h/(total+1)]
  end
end
