class RDDR::GTKObject
  include Serializable

  attr_gtk

  def args
    $gtk.args
  end
end
