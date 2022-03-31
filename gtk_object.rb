class RDDR::GTKObject
  include RDDR::Serializable

  attr_gtk

  def args
    $gtk.args
  end

  def debug_puts(...)
    return unless state.rddr_debug_mode

    puts(...)
  end
end
