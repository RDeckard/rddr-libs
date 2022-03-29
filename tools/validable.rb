module RDDR::Validable
  def self.included(base)
    base.include InstanceMethods
    base.extend  ClassMethods
  end

  module ClassMethods
    MAJUSCULES = ('A'..'Z').to_a

    Validation =
      Struct.new(:attribute, :condition, :error_message) do
        define_method(:error_message_call) do |object|
          case error_message
          when Proc
            error_message.(object)
          when String
            error_message
          when nil
            "'#{object.__send__(attribute)}' is not permitted"
          end
        end
      end

    def inherited(sub_class)
      # validations are inheritable,but not shared between sibling,
      # hence the fact that we don't use a class variable (that behave like this without the #dup)
      sub_class.instance_variable_set("@validations", validations.dup)
    end

    def validations
      @validations ||= []
    end

    def validates(attribute, condition, error_message: nil)
      validations << Validation.new(attribute, condition, error_message)
    end

    # snakecase the class name (mruby doesn't have Regexp natively)
    def instance_name
      @instance_name ||=
        name.
          split("::").last. # get the highest level constant name
          chars.map.with_index do |char, i| # first step for snakecase...
            next char if i.zero? || !char.in?(MAJUSCULES)

            "_#{char}"
          end.join.
          downcase # ... and downcasing the all
    end
  end

  module InstanceMethods
    Error =
      Struct.new(:attribute, :message) do
        define_method(:inspect) { "#<#{self.class.name}: #{message}>" }
      end

    def errors
      @errors ||= []
    end

    def valid?
      @errors = []

      self.class.validations.each do |validation|
        next if @errors.any? { |error| error.attribute == validation.attribute } || validation.condition.(self)

        @errors << Error.new(
          validation.attribute,
          "#{validation.attribute} #{validation.error_message_call(self)}"
        )
      end

      @errors.empty?
    end

    def validate!
      return true if valid?

      raise "Invalid #{instance_name}: #{@errors.map(&:message).join(", ")}."
    end

    def instance_name
      self.class.instance_name
    end
  end
end
