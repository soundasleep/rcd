require 'curses'
include Curses    # I think this means, import curses.*

init_screen     # or, Curses.init_screen
nl
noecho
srand

# create a "map"
class Map
  @width = 20
  @height = 20

  def initialize
    @data = Array.new(width * height, 0)
  end

  def height
    10
  end
  def width
    50
  end
  def data
    @data
  end
end

map = Map.new()

for i in 0..4
  x = (rand(map.height) * map.width) + rand(map.width)
  map.data[x] = 1;
end

def draw_map(map)
  for y in 0..map.height
    setpos 2 + y, 2
    for x in 0..map.width
      case map.data[(y * map.width) + x]
      when 1
        addstr "X"
      else
        addstr "."
      end
    end
  end
  refresh
end

# s = stdscr

draw_map(map)
sleep 1