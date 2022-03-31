module RDDR::Serializable
  EXCLUDED_ATTRIBUTES_FROM_SERIALIZATION = [].freeze

  def serialize
    instance_variables.
      to_h do |instance_variable_name|
        ivar_name = instance_variable_name.to_s.delete_prefix!("@").to_sym

        [ivar_name, instance_variable_get(instance_variable_name)]
      end.
      delete_if { |k, _| excluded_attributes_from_serialization.include?(k) }
  end

  def inspect
    serialize.to_s
  end

  def to_s
    serialize.to_s
  end

  def excluded_attributes_from_serialization
    self.class::EXCLUDED_ATTRIBUTES_FROM_SERIALIZATION
  end
end
