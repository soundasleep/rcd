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
    10
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

map = Map.new()
player = Player.new(10, 5)

max_screen_width = 10
max_screen_height = 10

for i in 0..25
  x = (rand(map.height) * map.width) + rand(map.width)
  map.data[x] = 1;
end
for i in 0..(map.height / 5)
  for x in 0..map.width
    map.data[((i * 5) * map.width) + x] = 1;
  end
end

def draw_map(map, player)
  for y in 0 .. map.height
    setpos 2 + y, 2
    for x in 0 .. map.width
      case map.data[(y * map.width) + x]
      when 1
        addstr "X"
      else
        addstr "."
      end
    end
  end

  # find the player
  setpos 2 + player.y, 2 + player.x
  addstr "@"

  i = 0
  setpos 15 + i, 2
  addstr "meow"

  instructions = [
    "   Q - quit", 
    "wasd - move"
  ]
  # for i in 0..instructions.length - this wasn't working
  i = 0
  for inst in instructions 
    setpos 15 + i, 2
    addstr inst
    i += 1
  end

  draw_instructions
  refresh
end

def draw_instructions

end

# s = stdscr

Thread.new(map, player) {
  loop do
    draw_map(map, player)
    #draw_instructions
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
    player.y += 1 unless player.y >= map.height
  when "a"
    player.x -= 1 unless player.x <= 0
  when "d"
    player.x += 1 unless player.x >= map.width
  end
end
