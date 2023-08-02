module RDDR::Geometry
  def relative_speed(speed1, angle1, speed2, angle2)
    speed1_x = angle1.vector_x * speed1
    speed1_y = angle1.vector_y * speed1
    speed2_x = angle2.vector_x * speed2
    speed2_y = angle2.vector_y * speed2

    dspeed_x = speed1_x - speed2_x
    dspeed_y = speed1_y - speed2_y

    Math.sqrt(dspeed_x**2 + dspeed_y**2)
  end
end

GTK::Geometry.extend RDDR::Geometry
