class SendableArray < Array
  def send(socket)
    copy = to_a
    socket.puts copy.size.to_s
    for obj in copy
      socket.puts sendTo(obj)
    end
  end

  def load(socket)
    size = socket.gets.to_i
    results = Array.new()
    for _ in 1..size
      results.push loadFrom(socket.gets)
    end
    replace(results)
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

class QueuedShotArray < SendableArray
  def loadFrom(str)
    bits = str.split(",")
    QueuedShot.new(bits[0].to_i, bits[1].to_i, bits[2].to_i, bits[3].to_i)
  end

  def sendTo(obj)
    obj.x.to_s + "," + obj.y.to_s + "," + obj.dx.to_s + "," + obj.dy.to_s
  end
end

class PlayerArray < SendableArray
  def loadFrom(str)
    bits = str.split(",")
    Player.new(bits[0].to_i, bits[1].to_i, bits[2])
  end

  def sendTo(obj)
    obj.x.to_s + "," + obj.y.to_s + "," + obj.name
  end

  def without(player)
    x = PlayerArray.new()
    select { |a| a != player }.each{ |a| x.push(a) }
    x
  end
end
