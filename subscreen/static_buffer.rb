class RDDR::StaticBuffer < RDDR::GTKObject
  attr_reader :buffer_name, :rect

  def initialize(buffer_name, rect)
    @buffer_name = buffer_name
    @rect = rect.dup.sprite!(path: @buffer_name)

    outputs[@buffer_name].w = @rect.w
    outputs[@buffer_name].h = @rect.h
    outputs[@buffer_name].static_primitives << [yield(@rect)].tap(&:flatten!).each { _1.x -= @rect.x; _1.y -= @rect.y }
  end

  # Pass a optional block to adapt the buffer.rect to render_target where the buffer will be rendered
  def as_sprite(object_to_follow: nil, parallax: 1)
    if object_to_follow
      @rect.merge!(
        x: object_to_follow.x * (1 - parallax),
        y: object_to_follow.y * (1 - parallax),
      )
    end

    if block_given?
      yield(@rect)
    else
      @rect
    end
  end
end
