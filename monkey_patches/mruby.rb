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
end

module Enumerable
  def sum(&block)
    map(&block).reduce(0) { |acc, element| acc += element }
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
    empty?
  end
end
