menu = {
  var = {
    main = {
      font = love.graphics.newFont(20),
      buttons = {
        {
          text = 'Singleplayer',
          action = function() 
            --game.switchState{'menu','worlds'} 
            game.switchState{'game'} 
          end
        },
        {
          text = 'Multiplayer',
          action = function()
            game.switchState{'menu','servers'}
          end
        },
        {
          text = 'Exit',
          action = function()
            love.event.quit()
          end
        },
        {
          text = 'WIP. Press space to start!'
        }
      }
    }
  }
}

function menu.draw()
  local g = love.graphics
  local w,h = g.getDimensions()
  
  if game.state[2]=='main' then
    local var = menu.var.main
    local f = var.font
    local fh = f:getHeight()
    g.setFont(f)
    g.translate(w/2,0)
    
    local maxw = 0
    for i,v in ipairs(var.buttons) do
      maxw = math.max(maxw, f:getWidth(v.text))
    end
    
    local ph = 2
    local mh,mw = 2,2
    for i,v in ipairs(var.buttons) do
      local t = v.text
      local fw = f:getWidth(t)
      local x = math.floor(-maxw/2)-mw*2
      local tx = math.floor(-fw/2)
      local rw,rh = maxw+mw*2,fh+mh*2
      --
      g.setColor(1,1,1,.7)
      g.rectangle('fill',x,0,rw,rh)
      g.setColor(v.color or {1,1,1})
      g.print(t,tx,mh)
      g.translate(0,rh+ph)
    end
    g.origin()
  end
  
end

--local c = math.sin(love.timer.getTime())^2

function menu.update(dt)
  if love.keyboard.isDown('space') then
    game.switchState{'game'}
  end
end