module RDDR::Geometry
  # The order matter between 1 and 2 matters for the returned angle (180° difference)
  def relative_speed(speed1:, angle1: 0, speed2:, angle2: 0, with_resulting_angle: false)
    speed1x = speed1 * angle1.vector_x
    speed1y = speed1 * angle1.vector_y
    speed2x = speed2 * angle2.vector_x
    speed2y = speed2 * angle2.vector_y

    speedx_diff = speed1x - speed2x
    speedy_diff = speed1y - speed2y

    Math.hypot(speedx_diff, speedy_diff).then do |relative_speed|
      next relative_speed unless with_resulting_angle

      resulting_angle = Math.atan2(speedy_diff, speedx_diff).to_degrees
      [relative_speed, resulting_angle]
    end
  end

  def impact_resolution(speed1: 1, angle1:, mass1: 1, speed2: 1, angle2:, mass2: 1)
    speed1x = speed1 * angle1.vector_x
    speed1y = speed1 * angle1.vector_y
    speed2x = speed2 * angle2.vector_x
    speed2y = speed2 * angle2.vector_y

    relative_speed = Math.hypot(speed1x - speed2x, speed1y - speed2y)

    total_mass = mass1 + mass2
    mass_diff = mass1 - mass2
    mass1_double = mass1 * 2
    mass2_double = mass2 * 2

    new_speed1x = (mass_diff * speed1x + mass2_double * speed2x) / total_mass
    new_speed2x = (mass1_double * speed1x - mass_diff * speed2x) / total_mass
    new_speed1y = (mass_diff * speed1y + mass2_double * speed2y) / total_mass
    new_speed2y = (mass1_double * speed1y - mass_diff * speed2y) / total_mass

    new_speed1 = Math.hypot(new_speed1x, new_speed1y)
    new_speed2 = Math.hypot(new_speed2x, new_speed2y)

    new_angle1 = Math.atan2(new_speed1y, new_speed1x).to_degrees
    new_angle2 = Math.atan2(new_speed2y, new_speed2x).to_degrees

    [new_speed1, new_angle1, new_speed2, new_angle2, relative_speed]
  end

  # Find all collisions of rect (or anything responding to #rect) or objects (need a block)
  # Give an optional radius_ratio if you want to use a circle instead of a rect (proportionally to the sum of rect larger sides)
  def find_all_collisions(*objects, radius_ratio: nil)
    objects = objects.flatten # and not #flatten! because we want to duplicate the array
    collisions = []

    until objects.empty?
      object1 = block_given? ? yield(objects.shift) : objects.shift

      collided_objects, objects =
        objects.partition do |object2|
          object2 = block_given? ? yield(object2) : object2

          if radius_ratio
            o1_collision_dist = object1.w.greater(object1.h)
            o2_collision_dist = object2.w.greater(object2.h)
            collision_distance = (o1_collision_dist + o2_collision_dist) * radius_ratio

            Geometry.point_inside_circle?(object1, object2, collision_distance)
          else
            Geometry.intersect_rect?(object1, object2)
          end
        end

      collisions << collided_objects.unshift(object1) if collided_objects.any?
    end

    collisions
  end

  def any_collision?(...)
    find_all_collisions(...).any?
  end
end

GTK::Geometry.extend RDDR::Geometry
