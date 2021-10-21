class RDDR::GTKObject
  include RDDR::Serializable

  attr_gtk

  def args
    $gtk.args
  end
end
