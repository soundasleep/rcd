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

          x = 1 if x < 1
          y = 1 if y < 1
          x = (width - 2) if x >= (width - 1)
          y = (height - 2) if y >= (height - 1)

          @data[(y * width) + x] = 2
        end
      end
    end

    # then, once we have generated all the rooms, generate single width corridors as connections
    for r in rooms
      c = rooms[r.connected]    # connected room

      # we do it both ways because 2..1 does nothing (.. is strictly incremental only)
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
    end

    # now find all unwalled edges and create walls
    for x in 0..width-1
      for y in 0..height-1

        # we don't need a wall if we've got something here
        next if @data[(y * width) + x] > 1

        top = (y > 0 and @data[((y - 1) * width) + x] > 1)
        bottom = (y < (height-1) and @data[((y + 1) * width) + x] > 1)
        left = (x > 0 and @data[(y * width) + (x - 1)] > 1)
        right = (x < (width-1) and @data[(y * width) + (x + 1)] > 1)
        tl = (y > 0 and x > 0 and @data[((y - 1) * width) + (x - 1)] > 1)
        tr = (y > 0 and x < (width-1) and @data[((y - 1) * width) + (x + 1)] > 1)
        bl = (y < (height-1) and x > 0 and @data[((y + 1) * width) + (x - 1)] > 1)
        br = (y < (height-1) and x < (width-1) and @data[((y + 1) * width) + (x + 1)] > 1)

        if top or bottom or left or right or tl or tr or bl or br
          @data[(y * width) + x] = 1
        end

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

  def blocked(x, y)
    @data[(y * width) + x] == 1
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
          addstr "."
        when 4
          addstr "."
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
    player.y -= 1 unless player.y <= 0 or map.blocked(player.x, player.y - 1)
  when "s"
    player.y += 1 unless player.y >= (map.height - 1) or map.blocked(player.x, player.y + 1)
  when "a"
    player.x -= 1 unless player.x <= 0 or map.blocked(player.x - 1, player.y)
  when "d"
    player.x += 1 unless player.x >= (map.width - 1) or map.blocked(player.x + 1, player.y)
  end
end
