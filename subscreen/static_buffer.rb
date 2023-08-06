class RDDR::StaticBuffer < RDDR::GTKObject
  attr_reader :buffer_name, :rect

  def initialize(buffer_name, rect)
    @buffer_name = buffer_name
    @rect = rect

    outputs[@buffer_name].w = @rect.w
    outputs[@buffer_name].h = @rect.h
    outputs[@buffer_name].static_primitives << yield(@rect)
  end

  # Pass a optional block to adapt the buffer.rect to render_target where the buffer will be rendered
  def as_sprite
    if block_given?
      yield(@rect)
    else
      @rect.dup
    end.sprite!(path: @buffer_name)
  end
end