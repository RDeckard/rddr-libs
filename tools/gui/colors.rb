module RDDR::Colors
  SETS = {
    classic: {
      black:   { r: 0,   g: 0,   b: 0   }.freeze,
      white:   { r: 255, g: 255, b: 255 }.freeze,
      red:     { r: 255, g: 0,   b: 0   }.freeze,
      lime:    { r: 0,   g: 255, b: 0   }.freeze,
      blue:    { r: 0,   g: 0,   b: 255 }.freeze,
      yellow:  { r: 255, g: 255, b: 0   }.freeze,
      cyan:    { r: 0,   g: 255, b: 255 }.freeze,
      magenta: { r: 255, g: 0,   b: 255 }.freeze,
      silver:  { r: 192, g: 192, b: 192 }.freeze,
      grey:    { r: 128, g: 128, b: 128 }.freeze,
      maroon:  { r: 128, g: 0,   b: 0   }.freeze,
      olive:   { r: 128, g: 128, b: 0   }.freeze,
      green:   { r: 0,   g: 128, b: 0   }.freeze,
      purple:  { r: 128, g: 0,   b: 128 }.freeze,
      teal:    { r: 0,   g: 128, b: 128 }.freeze,
      navy:    { r: 0,   g: 0,   b: 128 }.freeze
    }.freeze,
    c64: {
      black:      { r: 0,   g: 0,   b: 0   }.freeze,
      white:      { r: 255, g: 255, b: 255 }.freeze,
      red:        { r: 136, g: 0,   b: 0   }.freeze,
      cyan:       { r: 170, g: 255, b: 238 }.freeze,
      violet:     { r: 204, g: 68,  b: 204 }.freeze,
      green:      { r: 0,   g: 204, b: 85  }.freeze,
      blue:       { r: 0,   g: 0,   b: 170 }.freeze,
      yellow:     { r: 238, g: 238, b: 119 }.freeze,
      orange:     { r: 221, g: 136, b: 85  }.freeze,
      brown:      { r: 102, g: 68,  b: 0   }.freeze,
      lightred:   { r: 255, g: 119, b: 119 }.freeze,
      darkgrey:   { r: 51,  g: 51,  b: 51  }.freeze,
      grey:       { r: 119, g: 119, b: 119 }.freeze,
      lightgreen: { r: 170, g: 255, b: 102 }.freeze,
      lightblue:  { r: 0,   g: 136, b: 255 }.freeze,
      lightgrey:  { r: 187, g: 187, b: 187 }.freeze
    }.freeze
  }.freeze
end
