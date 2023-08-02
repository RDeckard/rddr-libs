require "lib/rddr-libs/rddr.rb"

# Patches
require "lib/rddr-libs/monkey_patches/geometry.rb"
require "lib/rddr-libs/monkey_patches/gtk_inputs.rb"
require "lib/rddr-libs/monkey_patches/mruby.rb"

# Base
require "lib/rddr-libs/serializable.rb"
require "lib/rddr-libs/gtk_object.rb"
require "lib/rddr-libs/tick.rb"

# Sprites
require "lib/rddr-libs/sprites/animatable.rb"
require "lib/rddr-libs/sprites/spriteable.rb"

# Tools
require "lib/rddr-libs/tools/gui/box.rb"
require "lib/rddr-libs/tools/gui/button.rb"
require "lib/rddr-libs/tools/gui/colors.rb"
require "lib/rddr-libs/tools/gui/text_inputs.rb"
require "lib/rddr-libs/tools/gui/prompt.rb"
require "lib/rddr-libs/tools/gui/slider.rb"
require "lib/rddr-libs/tools/gui/text_box.rb"
require "lib/rddr-libs/tools/timer.rb"
require "lib/rddr-libs/tools/validable.rb"

# Subscreen
require "lib/rddr-libs/subscreen/concerns/shakeable.rb"
require "lib/rddr-libs/subscreen/subscreen.rb"
require "lib/rddr-libs/subscreen/camera.rb"
require "lib/rddr-libs/subscreen/entity.rb"
