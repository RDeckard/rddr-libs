class RDDR::GTKObject
  attr_gtk

  def args
    $gtk.args
  end

  def serialize
    instance_variables.
      to_h do |instance_variable_name|
        ivar_name = instance_variable_name.to_s.delete_prefix!("@").to_sym

        [ivar_name, instance_variable_get(instance_variable_name)]
      end
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end
end
