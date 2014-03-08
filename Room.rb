# create a "map"
class Room
  def initialize(x, y, width, height)
    @x = x
    @y = y
    @width = width
    @height = height
  end

  attr_reader :x, :y, :width, :height
  attr :connected, true
end
