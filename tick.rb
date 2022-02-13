class RDDR::Tick < RDDR::GTKObject
  def initialize(first_scene, debug: false)
    @first_scene = first_scene
    @debug = debug
  end

  def call
    debug if @debug

    args.state.current_scene ||= @first_scene.new

    state.current_scene.tick

    handle_quit_and_reset
  end

  def handle_quit_and_reset
    if inputs.keyboard.key_held.alt && inputs.keyboard.key_down.f
      state.window_fullscreen = !state.window_fullscreen
      gtk.set_window_fullscreen(state.window_fullscreen)
    end

    if inputs.keyboard.key_held.alt && inputs.keyboard.key_down.q
      gtk.request_quit unless gtk.platform?(:html)
      gtk.reset
    end

    gtk.reset if inputs.keyboard.key_held.alt && inputs.keyboard.key_down.r
  end

  def debug
    if @last_tick_time
      now = Time.now.to_f
      tps = 1/(now - @last_tick_time)

      outputs.debug << {
        x: grid.left.shift_right(5), y: grid.top.shift_down(5),
        text: "TPS: #{tps.to_i}",
        size_enum: 2,
        r: 255, g: 0, b: 0
      }.label!

      if @last_print_time.nil? || now - @last_print_time >= 1
        h = {}
        puts "------"
        puts "SCENE: #{state.current_scene.class.name}"
        puts "TPS: #{tps}"
        puts "PRIMITIVES: #{outputs.static_primitives.flatten.size}"
        puts ObjectSpace.count_objects(h)
        puts "------"
        @last_print_time = Time.now.to_f
      end
    end
    @last_tick_time = Time.now.to_f
  end
end
