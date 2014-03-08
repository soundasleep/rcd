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

for i in 0..25
  x = (rand(map.height) * map.width) + rand(map.width)
  map.data[x] = 1;
end

def draw_map(map, player)
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

  # find the player
  setpos 2 + player.y, 2 + player.x
  addstr "@"
  refresh
end

# s = stdscr

Thread.new(map, player) {
  loop do
    draw_map(map, player)
    sleep 0.05
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
