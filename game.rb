require 'curses'
include Curses    # I think this means, import curses.*

require_relative 'Room'
require_relative 'Map'
require_relative 'TwoDimensionalObject'
require_relative 'Player'
require_relative 'Monster'
require_relative 'Explosion'
require_relative 'Interface'

init_screen     # or, Curses.init_screen
nl
noecho
srand

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
monsters = Array.new()
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
explosions = Array.new()

# test that draw_map works correctly
interface.draw_map(map, player, monsters, explosions)
refresh

Thread.new(map, player, monsters, interface, explosions) {
  loop do
    interface.draw_map(map, player, monsters, explosions)
    interface.draw_instructions()
    refresh
    sleep 0.01
    # delete all "old" explosions
    explosions.each { |a| a.age -= 1 }
    explosions.delete_if { |a| a.age <= 0 }
  end
}

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
