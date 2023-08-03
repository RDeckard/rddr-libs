module RDDR::Geometry
  # The order matter between 1 and 2 matters for the returned angle (180° difference)
  def relative_speed(speed1, angle1, speed2, angle2, with_angle: false)
    speed1_x = angle1.vector_x * speed1
    speed1_y = angle1.vector_y * speed1
    speed2_x = angle2.vector_x * speed2
    speed2_y = angle2.vector_y * speed2

    dspeed_x = speed1_x - speed2_x
    dspeed_y = speed1_y - speed2_y

    Math.hypot(dspeed_x, dspeed_y).then do |dspeed|
      next dspeed unless with_angle

      Math.atan2(dspeed_y, dspeed_x).then do |rangle|
        [dspeed, Math.degrees(rangle)]
      end
    end
  end

  # Find all collisions of rect (or anything responding to #rect) or objects (need a block)
  # Give an optional radius_ratio if you want to use a circle instead of a rect (proportionally to the rect larger side)
  def find_all_collisions(objects, radius_ratio: false)
    objects = objects.dup
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

            Geometry.distance(object1, object2) <= collision_distance
          else
            Geometry.intersect_rect?(object1, object2)
          end
        end

      collisions << collided_objects.unshift(object1) if collided_objects.any?
    end

    collisions
  end
end

GTK::Geometry.extend RDDR::Geometry
