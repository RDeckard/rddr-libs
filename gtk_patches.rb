class GTK::Inputs
  def pointer
    Pointer
  end
end

module Pointer
  extend self

  def inputs
    $gtk.args.inputs
  end

  def state
    $gtk.args.state
  end

  def left_click
    mouse_left_click || touch_left_click
  end

  def right_click
    mouse_right_click
  end

  def mouse_left_click
    inputs.mouse.click && inputs.mouse.button_left
  end

  def mouse_right_click
    inputs.mouse.click && inputs.mouse.button_right
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

# Monkey Patches
class Object
  def blank?
    !self
  end

  def present?
    !blank?
  end

  def presence
    self if present?
  end
end

module Enumerable
  def sum(&block)
    map(&block).reduce(0) { |acc, element| acc += element }
  end

  def blank?
    empty?
  end

  def many?
    !none? && !one?
  end
end

class String
  def blank?
    empty?
  end
end
