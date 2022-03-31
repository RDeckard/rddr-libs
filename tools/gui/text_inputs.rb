class RDDR::TextInputs < RDDR::GTKObject
  def initialize(prompts:, box_rect: grid.rect, border_thickness: nil, mode: :sequential)
    @prompts          = prompts
    @box_rect         = box_rect
    @border_thickness = border_thickness
    @mode             = mode

    @updated_primitives = []
    @static_primitives  = []
  end

  def call
    case @mode
    when :flat       then flat_tick
    when :sequential then sequential_tick
    end
  end

  def flat_tick
    @active_prompt_index ||= 0

    @updated_primitives = []
    @static_primitives  = []

    @prompts.each_with_index do |prompt, i|
      i == @active_prompt_index ? prompt.enable! : prompt.disable!

      center = compute_line_center(i+1, total: @prompts.count)
      prompt.place!(*center).call(@box_rect.w)

      if prompt.enable
        @updated_primitives << prompt.updated_labels
      else
        @static_primitives << prompt.updated_labels
      end
    end

    @active_prompt_index += 1 if inputs.keyboard.key_down.down
    @active_prompt_index -= 1 if inputs.keyboard.key_down.up

    if inputs.keyboard.key_down.enter || inputs.pointer.left_click
      @active_prompt_index += 1 if @prompts[@active_prompt_index].run_validation

      if @active_prompt_index >= @prompts.count && @prompts.all?(&:run_validation)
        return :done
      else
        return :new_field
      end
    end

    @active_prompt_index = 0 if @active_prompt_index >= @prompts.count
    @active_prompt_index = @prompts.count - 1 if @active_prompt_index < 0
  end

  def sequential_tick
    @current_prompt ||= next_prompt

    if @current_prompt
      result = @current_prompt.call(@box_rect.w)

      @updated_primitives = @current_prompt.updated_labels

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
    @compute_line_center_box = @box_rect

    [@compute_line_center_box.left + @compute_line_center_box.w/2,
     @compute_line_center_box.top - n*@compute_line_center_box.h/(total+1)]
  end

  def primitives
    (box_primitives + @static_primitives + @updated_primitives).tap(&:flatten!)
  end

  def updated?
    @updated_primitives.flatten.any?
  end

  def box_primitives
    @box_primitives ||=
      if @border_thickness
        RDDR::Box.new(@box_rect, border_thickness: @border_thickness, background_color: :silver).primitives
      else
        []
      end
  end
end
