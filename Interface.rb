class Interface
  def max_width
    70
  end
  def max_height
    20
  end

  def draw_map(map, player, monsters)
    for dy in 0..max_height
      y = player.y - (max_height / 2) + dy
      setpos 1 + dy, 2
      for dx in 0..max_width
        x = player.x - (max_width / 2) + dx

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

    # find the monsters, which may be out of the map
    for monster in monsters
      if monster.x >= player.x - (max_width / 2) and monster.x <= player.x + (max_width / 2)
        if monster.y >= player.y - (max_height / 2) and monster.y <= player.y + (max_height / 2)
          x = monster.x - player.x + (max_width / 2)
          y = monster.y - player.y + (max_height / 2)
          setpos 1 + y, 2 + x
          addstr "%"
        end
      end
    end

    # find the player, always in the centre
    # setpos 2 + player.y, 2 + player.x
    setpos 1 + (max_height / 2), 2 + (max_width / 2)
    addstr "@"

    setpos max_height + 3, 2
    addstr "(" + player.x.to_s + "," + player.y.to_s + ")"

  end

  def draw_instructions
    instructions = [
      "   Q - quit", 
      "wasd - move"
    ]
    # for i in 0..instructions.length - this wasn't working
    i = 0
    for inst in instructions 
      setpos max_height + 4 + i, 2
      addstr inst
      i += 1
    end
  end

end
