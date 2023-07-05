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

  def geometry
    args.geometry
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
end
