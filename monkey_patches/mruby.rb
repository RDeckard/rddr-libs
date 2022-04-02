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
  def blank?
    delete(" ").empty?
  end

  def first(n = 1)
    self[0, n]
  end

  def last(n = 1)
    self[-n, n]
  end
end
