class RDDR::Tick < RDDR::GTKObject
  def initialize(first_scene, debug_mode: false)
    change_scene!(first_scene)

    state.rddr_debug_mode = debug_mode
  end

  def call
    current_scene.tick

    debug! if state.rddr_debug_mode
    handle_quit_and_reset
  end

  def change_scene!(scene_class)
    state.current_scene = scene_class.new
    current_scene.init
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

    return if gtk.production?

    gtk.reset if inputs.keyboard.key_held.alt && inputs.keyboard.key_down.r
    state.rddr_debug_mode = !state.rddr_debug_mode if inputs.keyboard.key_held.alt && inputs.keyboard.key_down.d
  end

  def debug!
    @tabulation = " " * 16
    @output_counter ||=
      lambda { |objects|
        objects.flatten!
        count = objects.size
        details =
          objects.map do |object|
            {
              primitive_marker: object.primitive_marker,
              path_or_class: (object.is_a?(Hash) ? object.path : object.class)
            }
          end.tally.sort_by { [-_2, _1[:primitive_marker]] }.map { "#{_2} #{_1[:primitive_marker]} #{_1[:path_or_class]}" }.join("\n#{@tabulation}")

        "(#{count})#{"\n#{@tabulation}" if details.present?}#{details}"
      }

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
        puts "SCENE: #{current_scene.class.name}"
        puts "TPS: #{tps}"
        puts "STATIC PRIMITIVES: #{@output_counter.(outputs.static_primitives)}"
        puts "PRIMITIVES: #{@output_counter.(outputs.primitives)}"
        puts "STATIC SOLIDS: #{@output_counter.(outputs.static_solids)}"
        puts "SOLIDS: #{@output_counter.(outputs.solids)}"
        puts "STATIC SPRITES: #{@output_counter.(outputs.static_sprites)}"
        puts "SPRITES: #{@output_counter.(outputs.sprites)}"
        puts "STATIC LABELS: #{@output_counter.(outputs.static_labels)}"
        puts "LABELS: #{@output_counter.(outputs.labels)}"
        puts "STATIC LINES: #{@output_counter.(outputs.static_lines)}"
        puts "LINES: #{@output_counter.(outputs.lines)}"
        puts "STATIC BORDERS: #{@output_counter.(outputs.static_borders)}"
        puts "BORDERS: #{@output_counter.(outputs.borders)}"
        puts "STATIC DEBUG: #{@output_counter.(outputs.static_debug)}"
        puts "DEBUG: #{@output_counter.(outputs.debug)}"
        state.render_targets&.each do |name|
          puts "--- #{name.inspect} ---"
          puts "-- STATIC PRIMITIVES: #{@output_counter.(outputs[name].static_primitives)}"
          puts "-- PRIMITIVES: #{@output_counter.(outputs[name].primitives)}"
          puts "-- STATIC SOLIDS: #{@output_counter.(outputs[name].static_solids)}"
          puts "-- SOLIDS: #{@output_counter.(outputs[name].solids)}"
          puts "-- STATIC SPRITES: #{@output_counter.(outputs[name].static_sprites)}"
          puts "-- SPRITES: #{@output_counter.(outputs[name].sprites)}"
          puts "-- STATIC LABELS: #{@output_counter.(outputs[name].static_labels)}"
          puts "-- LABELS: #{@output_counter.(outputs[name].labels)}"
          puts "-- STATIC LINES: #{@output_counter.(outputs[name].static_lines)}"
          puts "-- LINES: #{@output_counter.(outputs[name].lines)}"
          puts "-- STATIC BORDERS: #{@output_counter.(outputs[name].static_borders)}"
          puts "-- BORDERS: #{@output_counter.(outputs[name].borders)}"
          puts "-- STATIC DEBUG: #{@output_counter.(outputs[name].static_debug)}"
          puts "-- DEBUG: #{@output_counter.(outputs[name].debug)}"
        end
        puts ObjectSpace.count_objects(h)
        puts "------"
        @last_print_time = Time.now.to_f
      end
    end

    @last_tick_time = Time.now.to_f
  end
end
