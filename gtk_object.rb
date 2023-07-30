class RDDR::GTKObject
  include RDDR::Serializable

  def gtk
    $gtk
  end

  def args
    $gtk.args
  end

  def state
    args.state
  end

  def grid
    args.grid
  end

  def layout
    args.layout
  end

  def inputs
    args.inputs
  end

  def outputs
    args.outputs
  end

  def debug_puts(...)
    return unless state.rddr_debug_mode

    puts(...)
  end

  # Conventions

  def game_tick
    state.game_tick
  end

  def current_scene
    state.current_scene
  end

  def game_state
    state.game
  end
end
