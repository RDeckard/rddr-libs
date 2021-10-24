class GTK::Inputs
  def pointer
    RDDR::Pointer
  end
end

module RDDR::Pointer
  extend self

  def inputs
    $gtk.args.inputs
  end

  def state
    $gtk.args.state
  end

  def inside_rect?(rect)
    inputs.mouse&.inside_rect?(rect) || inputs.finger_one&.inside_rect?(rect)
  end

  def left_click
    mouse_left_click || touch_left_click
  end

  def right_click
    mouse_right_click
  end

  def mouse_left_click
    inputs.mouse.button_left && inputs.mouse.click
  end

  def mouse_right_click
    inputs.mouse.button_right && inputs.mouse.click
  end

  # TO TEST
  def touch_left_click
    if inputs.touch.values.one?
      @finger_one_at = state.tick_count unless @finger_one_at
    elsif @finger_one_at
      if state.tick_count - @finger_one_at < 10
        click = true
      else
        @finger_one_at = false
      end
    end

    click
  end
end
