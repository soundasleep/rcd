require 'curses'
include Curses    # I think this means, import curses.*

init_screen     # or, Curses.init_screen
nl
noecho
srand

# create a "map"
class Map
  def initialize
    @data = Array.new(width * height, 0)
  end

  def height
    50
  end
  def width
    50
  end
  def data
    @data
  end
end

class Player
  def initialize(x, y)
    @x = x
    @y = y
  end

  def x
    @x
  end
  def y
    @y
  end
  def x=(a)
    @x=a
  end
  def y=(a)
    @y=a
  end
end

class Interface
  def max_width
    30
  end
  def max_height
    11
  end
end

map = Map.new()
player = Player.new(10, 5)
interface = Interface.new()

for i in 0..25
  x = (rand(map.height) * map.width) + rand(map.width)
  map.data[x] = 1;
end
for i in 0..(map.height / 5)
  for x in 0..map.width
    map.data[((i * 5) * map.width) + x] = 1;
  end
end

def draw_map(map, player, interface)
  for dy in 0..interface.max_height
    y = player.y - (interface.max_height / 2) + dy
    setpos 1 + dy, 2
    for dx in 0..interface.max_width
      x = player.x - (interface.max_width / 2) + dx

      if x < 0 or y < 0 or x >= map.width or y >= map.height
        addstr " "    # out of bounds
      else
        case map.data[(y * map.width) + x]
        when 1
          addstr "X"
        else
          addstr "."
        end
      end
    end
  end

  # find the player
  # setpos 2 + player.y, 2 + player.x
  setpos 2 + (interface.max_height / 2), 2 + (interface.max_width / 2)
  addstr "@"

  setpos interface.max_height + 3, 2
  addstr "(" + player.x.to_s + "," + player.y.to_s + ")"

end

def draw_instructions(interface)
  instructions = [
    "   Q - quit", 
    "wasd - move"
  ]
  # for i in 0..instructions.length - this wasn't working
  i = 0
  for inst in instructions 
    setpos interface.max_height + 4 + i, 2
    addstr inst
    i += 1
  end
end

# s = stdscr

Thread.new(map, player, interface) {
  loop do
    draw_map(map, player, interface)
    draw_instructions(interface)
    refresh
    sleep 0.01
  end
}

# input thread
# since ruby chomps up errors in a separate thread, we keep this on the mainthread
loop do
  case getch
  when "Q"
    exit
  when "w"
    player.y -= 1 unless player.y <= 0
  when "s"
    player.y += 1 unless player.y >= (map.height - 1)
  when "a"
    player.x -= 1 unless player.x <= 0
  when "d"
    player.x += 1 unless player.x >= (map.width - 1)
  end
end
