module Spriteable
  DEFAULT_SPRITE = "pixel"

  def primitive_marker
    :sprite
  end

  def draw_override(ffi_draw)
    params = draw_parameters

    ffi_draw.draw_sprite_4(
      params[:x], params[:y],                                                     # x, y,
      params[:w], params[:h],                                                     # w, h,
      params[:path] || DEFAULT_SPRITE, params[:angle],                            # path, angle,
      params[:alpha], params[:r], params[:g], params[:b],                         # alpha, red, green, blue,
      params[:tile_x], params[:tile_y], params[:tile_w], params[:tile_h],         # tile_x, tile_y, tile_w, tile_h,
      params[:flip_horizontally], params[:flip_vertically],                       # flip_horizontally, flip_vertically,
      params[:angle_anchor_x], params[:angle_anchor_y],                           # angle_anchor_x, angle_anchor_y,
      params[:source_x], params[:source_y], params[:source_w], params[:source_h], # source_x, source_y, source_w, source_h,
      params[:blendmode_enum]                                                     # blendmode_enum
    )
  end
end
