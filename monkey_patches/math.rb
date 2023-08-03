module RDDR::Math
  def degrees(radians)
    radians * 180 / Math::PI
  end

  def radians(degrees)
    degrees * Math::PI / 180
  end
end

Math.extend RDDR::Math
