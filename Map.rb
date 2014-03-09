class Map
  def initialize
    @height = 100
    @width = 100
  end

  attr :width, true
  attr :height, true

  def send(socket)
    socket.puts width.to_s
    socket.puts height.to_s
    for i in 0..(height * width)-1
      socket.puts @data[i].to_s
    end
  end

  def load(socket)
    width = socket.gets.to_i
    height = socket.gets.to_i
    @data = Array.new(width * height, 0)
    for i in 0..(height * width)-1
      @data[i] = socket.gets.to_i
    end
  end

  def generate
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

  def data
    @data
  end

  def blocked(x, y)
    valid(x, y) and @data[(y * width) + x] == 1
  end
  def valid(x, y)
    x >= 0 and y >= 0 and x < width and y < height
  end
end
