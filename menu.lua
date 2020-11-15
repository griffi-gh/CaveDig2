menu = {}

function menu.draw()
  local g = love.graphics
  g.scale(math.abs(math.sin(love.timer.getTime())*10))
  g.setColor(love.math.random(),love.math.random(),love.math.random())
  g.print'Awesum menuy\nclIckk scaPE!11!!!!1\n \t\t\tto pALY'
  g.setColor(1,1,1)
end

function menu.update(dt)
  if love.keyboard.isDown('space') then
    game.switchState{'game'}
  end
end