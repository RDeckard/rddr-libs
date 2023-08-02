class Object
  # support ranges for #rand
  def rand(arg = nil)
    return super(arg) unless arg.is_a?(Range)

    super(arg.max - arg.min + 1) + arg.min
  end

  def blank?
    !self
  end

  def present?
    !blank?
  end

  def presence
    self if present?
  end

  def in?(collection)
    collection.include?(self)
  end
end

module Enumerable
  def sum(&block)
    filter_map(&block).reduce(0) { |acc, element| acc += element }
  end

  def blank?
    empty?
  end

  def many?
    !none? && !one?
  end
end

class String
  CAPITALS = ("A".."Z").to_a.join.freeze
  SEPARATORS_STRING = "_ -".freeze
  SEPARATORS = "_ -".chars.freeze

  def blank?
    delete(" ").empty?
  end

  def first(n = 1)
    self[0, n]
  end

  def last(n = 1)
    self[-n, n]
  end

  def -@
    freeze
  end

  def +@
    dup
  end

  # mruby lacks Regexp
  def underscore
    return "" if blank?

    new_string = chars.first
    return new_string if length == 1

    chars.each_cons(2).with_object(new_string) do |(previous_char, char), _|
      new_char = !CAPITALS.include?(previous_char) && CAPITALS.include?(char) ? "_#{char}" : char
      new_string << new_char
    end
    .tap { _1.downcase! }
    .tap { _1.tr!(SEPARATORS_STRING, "_") }
  end

  # mruby lacks Regexp
  def camelize
    return "" if blank?

    new_string = chars.first.upcase
    return new_string if length == 1

    chars.each_cons(2).with_object(new_string) do |(previous_char, char), _|
      char.upcase! if SEPARATORS.include?(previous_char)
      new_string << char
    end
    .tap { _1.tr!(SEPARATORS_STRING, "") }
  end
end
