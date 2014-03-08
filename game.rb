require 'curses'
include Curses    # I think this means, import curses.*

init_screen     # or, Curses.init_screen
nl
noecho
srand

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

class Map
  def initialize
    @data = Array.new(width * height, 0)

    # lets initialise some rooms and stuff
    rooms = Array.new()
    for i in 0..(width / 10)
      room = Room.new(1 + rand(width - 2), 1 + rand(height - 2), rand(8) + 2, rand(5) + 2)
      room.connected = rand(rooms.length)
      room.connected = 1 if i == 0
      rooms.push room
    end

    # now create the rooms on the map
    for r in rooms
      for dx in -r.width .. r.width
        for dy in -r.height .. r.height
          x = dx + r.x
          y = dy + r.y

          x = 0 if x < 0
          y = 0 if y < 0
          x = (width - 1) if x >= width
          y = (height - 1) if y >= height

          @data[(y * width) + x] = 2
        end
      end
    end

    # then, once we have generated all the rooms, generate single width corridors as connections
    for r in rooms
      c = rooms[r.connected]    # connected room

      # case rand(1)
      # when 0, 1
        # do x first, then y
        for x in r.x .. c.x
          @data[(r.y * width) + x] = 4
        end
        for y in r.y .. c.y
          @data[(y * width) + c.x] = 3
        end
        for x in c.x .. r.x
          @data[(r.y * width) + x] = 4
        end
        for y in c.y .. r.y
          @data[(y * width) + c.x] = 3
        end
      #when 1
      #   # TODO do y first, then x
      # end
    end

    # now find all unwalled edges and create walls
    for x in 0..width
      for y in 0..height

      end
    end
  end

  def height
    100
  end
  def width
    100
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

  attr :x, true
  attr :y, true

  # equivalent to:
  # def x
  #   @x
  # end
  # def y
  #   @y
  # end
  # def x=(a)
  #   @x=a
  # end
  # def y=(a)
  #   @y=a
  # end
end

class Interface
  def max_width
    70
  end
  def max_height
    20
  end
end

map = Map.new()
player = nil
loop do
  x = rand(map.height)
  y = rand(map.width)
  if map.data[(y * map.width) + x] == 2
    player = Player.new(x, y)
    break
  end
end
interface = Interface.new()

def draw_map(map, player, interface)
  for dy in 0..interface.max_height
    y = player.y - (interface.max_height / 2) + dy
    setpos 1 + dy, 2
    for dx in 0..interface.max_width
      x = player.x - (interface.max_width / 2) + dx

      if x < 0 or y < 0 or x >= map.width or y >= map.height
        addstr "Z"    # out of bounds
      else
        case map.data[(y * map.width) + x]
        when 1
          addstr "X"
        when 2
          addstr "."
        when 3
          addstr ","
        when 4
          addstr ";"
        else
          addstr " "
        end
      end
    end
  end

  # find the player
  # setpos 2 + player.y, 2 + player.x
  setpos 1 + (interface.max_height / 2), 2 + (interface.max_width / 2)
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
