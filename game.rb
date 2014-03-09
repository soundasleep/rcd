require 'curses'
include Curses    # I think this means, import curses.*

require 'socket'

require_relative 'Room'
require_relative 'Map'
require_relative 'TwoDimensionalObject'
require_relative 'Player'
require_relative 'Monster'
require_relative 'Explosion'
require_relative 'Interface'

class SendableArray < Array
  def send(socket)
    socket.puts size.to_s
    for obj in self
      socket.puts sendTo(obj)
    end
  end

  def load(socket)
    size = socket.gets.to_i
    clear()
    for _ in 1..size
      push loadFrom(socket.gets)
    end
  end

  # need to implement local method loadFrom and sendTo
end

class MonsterArray < SendableArray
  def loadFrom(str)
    bits = str.split(",")
    Monster.new(bits[0].to_i, bits[1].to_i)
  end

  def sendTo(obj)
    obj.x.to_s + "," + obj.y.to_s
  end
end

class ExplosionArray < SendableArray
  def loadFrom(str)
    bits = str.split(",")
    Explosion.new(bits[0].to_i, bits[1].to_i)
  end

  def sendTo(obj)
    obj.x.to_s + "," + obj.y.to_s
  end
end

class PlayerArray < SendableArray
  def loadFrom(str)
    bits = str.split(",")
    Player.new(bits[0].to_i, bits[1].to_i)
  end

  def sendTo(obj)
    obj.x.to_s + "," + obj.y.to_s
  end

  def without(player)
    x = PlayerArray.new()
    select { |a| a != player }.each{ |a| x.push(a) }
    x
  end
end

PORT = 19065
TICK = 0.2    # send new data between server/client every TICK seconds

map = nil
monsters = nil
explosions = nil
player = nil
players = nil

interface = Interface.new()

def createPlayer(map)
  loop do
    x = rand(map.height)
    y = rand(map.width)
    if map.data[(y * map.width) + x] == 2
      return Player.new(x, y)
    end
  end
end

# set up server
if server
  map = Map.new()
  map.generate()

  monsters = MonsterArray.new()
  for _ in 1..20
    loop do
      x = rand(map.height)
      y = rand(map.width)
      if map.data[(y * map.width) + x] == 2
        monsters.push Monster.new(x, y)
        break
      end
    end
  end
  explosions = ExplosionArray.new()
  players = PlayerArray.new()

  # create the player - TODO in the future create multiple players
  player = createPlayer(map)
  players.push player

  # and listen on a thread
  server = TCPServer.new PORT
  Thread.new(server, interface) {
    loop do
      Thread.start(server.accept) do |client|
        begin
          interface.message = "New connection"
          map.send client
          # then load the player
          newPlayer = Player.new(-1,-1)
          newPlayer.load(client)
          players.push newPlayer
          interface.message = "Loaded player "
          interface.message = "Loaded player " + newPlayer.to_s
          loop do
            # regularly send data
            newPlayer.load(client)
            interface.message = "Updated player " + newPlayer.to_s
            monsters.send client
            explosions.send client            
            players.without(newPlayer).send client   # don't send this player; they already know where they are
            interface.message = "Sent data"
            sleep TICK
          end
          interface.message = "" + client.to_s + " disconnected"
        rescue => e
          interface.message = "Error " + e.to_s + e.backtrace.join(" ")
        end
      end
    end
  }
else
  puts "What server/IP would you like to connect to?"
  ip = gets.strip()

  puts "Connecting..."

  socket = TCPSocket.new ip, PORT
  puts "Loading map..."

  # load the map
  map = Map.new()
  map.load socket
  interface.message = "Loaded map"

  # create the player (after the map is loaded) - TODO in the future create multiple players
  player = createPlayer(map)
  player.send socket
  interface.message = "Sent initial player"

  # everything else (players, monsters) is sent by the server regularly
  monsters = MonsterArray.new()
  explosions = ExplosionArray.new()
  players = PlayerArray.new()
  Thread.new(monsters, explosions) {
    begin
      loop do
        player.send socket
        interface.message = "Updated player"
        monsters.load socket
        explosions.load socket
        players.load socket
        interface.message = "Received data"
        # we don't sleep here because we'll block on load() waiting for data
        # (i.e. the server controls the data rate)
      end
    rescue => e
      interface.message = e.to_s
      puts e
    end
  }
end

# after we have set up connection, start rendering
init_screen     # or, Curses.init_screen
nl
noecho
srand

# test that draw_map works correctly
interface.draw_map(map, player, players, monsters, explosions)
refresh

Thread.new(map, player, players, monsters, interface, explosions) {
  loop do
    interface.draw_map(map, player, players, monsters, explosions)
    interface.draw_instructions()
    refresh
    sleep 0.01
    # delete all "old" explosions
    explosions.each { |a| a.age -= 1 }
    explosions.delete_if { |a| a.age <= 0 }
  end
}

if server
  # test that wander works correctly
  monsters[0].wander(map)

  Thread.new(map, player, monsters) {
    loop do
      sleep 1
      for monster in monsters
        # move randomly
        monster.wander(map)
      end
    end
  }
end

# "shoot" something from x,y in the direction dx,dy until it hits either a player or a monster
def shoot(x, y, dx, dy, map, monsters, explosions)
  loop do
    # apply dx,dy immediately so we don't hit ourselves
    x += dx
    y += dy

    break unless map.valid(x, y)

    if map.blocked(x, y)
      explosions.push(Explosion.new(x, y))
      break
    end

    # loop through all monsters
    for m in monsters
      if m.x == x and m.y == y
        monsters.delete(m)
        explosions.push(Explosion.new(x, y))
        return  # we've hit something, don't go through them
      end
    end

    # TODO loop through all players
  end
end

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
  when "W"
    shoot(player.x, player.y, 0, -1, map, monsters, explosions)
  when "S"
    shoot(player.x, player.y, 0, 1, map, monsters, explosions)
  when "A"
    shoot(player.x, player.y, -1, 0, map, monsters, explosions)
  when "D"
    shoot(player.x, player.y, 1, 0, map, monsters, explosions)
  end
end
