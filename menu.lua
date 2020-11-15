local F = string.format

menu = {
  var = {
    main = {
      logo = 'MAIN MENU',
      font = love.graphics.newFont(20),
      bigFont = love.graphics.newFont(100),
      background = love.graphics.newImage('res/dirt.png'),
      background_quad = nil,
      scrSpeed = 1,
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
          action = function(self,i)
            table.remove(menu.var.main.buttons,i)
          end
        },
        {
          text = 'Options',
          action = function(self,i)
            table.remove(menu.var.main.buttons,i)
          end
        },
        {
          text = 'toggleDebug',
          action = function(self)
            local c = game.config.debug
            for i,v in pairs(c) do
              c[i]=not c[i]
            end
          end
        },
        {
          text = 'Exit',
          action = function()
            love.event.quit()
          end,
          bgHoverColor = {1,.2,.2,.7},
          borderHoverColor = {.3,0,0}
        }
      }
    }
  }
}

do
  menu.var.main.background:setWrap("repeat", "repeat")
  local iw,ih = menu.var.main.background:getDimensions()
  menu.var.main.background_quad = love.graphics.newQuad(
    0,0,
    love.graphics.getWidth()+iw,
    love.graphics.getHeight()+ih,
    iw,ih
  )
end

local function off(x,s,d)
  return -((x*s)%1)*d
end

local mdp
function menu.draw()
  local g = love.graphics
  local w,h = g.getDimensions()
  local mx,my = love.mouse.getPosition()
  local mdr = love.mouse.isDown(1)
  local md = mdr and not mdp
  local md2 = mdp and not mdr
  mdp = mdr
  if game.state[2]=='main' then
    local var = menu.var.main
    
    do --background
      local bw,bh = var.background:getDimensions()
      local t = love.timer.getTime()
      local sp = var.scrSpeed
      love.graphics.draw(
        var.background,
        var.background_quad,
        off(t,sp,bw),
        off(t,sp,bh)
      )
    end
    
    do --logo
      local f = var.bigFont
      local t = var.logo
      g.setFont(f)
      g.setColor(1,1,1)
      g.print(
        t,
        math.floor((w-f:getWidth(t))/2),
        math.floor(h/4-f:getHeight()/2)
      )
    end
    
    do --buttons
      local f = var.font
      local fh = f:getHeight()
      g.setFont(f)
      
      local maxw = 0
      for i,v in ipairs(var.buttons) do
        maxw = math.max(maxw, f:getWidth(v.text))
      end
      
      local menuy = h/2
      local ph = 4
      local mw,mh = 8,3
      
      local minmw = 2
      
      g.origin()
      
      local trx,try = w/2,menuy+ph
      g.translate(trx,try)
      for i,v in ipairs(var.buttons) do
        v.hovt = v.hovt or 0
        v.clkt = v.clkt or 0
        local t = v.text
        local fw = f:getWidth(t)
        local x = math.floor(-maxw/2)-mw
        local y = 0
        local tx = math.floor(-fw/2)
        local rw,rh = maxw+mw*2,fh+mh*2
        local h = mx>trx+x and mx<trx+x+rw and my>try+y and my<try+rh+y
        --
        local hf = .1*love.timer.getDelta()*60
        if h then
          v.hovt = math.min(1,v.hovt+hf)
          if mdr then
            v.clkt = math.min(1,v.clkt+hf*4)
          end
          if v.action and md2 then
            v:action(i)
          end
        else
          v.hovt = math.max(0,v.hovt-hf)
          v.clkt = math.max(0,v.clkt-hf)
        end
        local vrw = rw-v.clkt*(mw-minmw)*2
        local vx = x+v.clkt*(mw-minmw)
        --
        local ch1 = v.bgHoverColor or {.6,.6,.6,.8}
        local cb1 = v.bgColor or {0,0,0,.65}
        local mx1 = mixColor(ch1,cb1,v.hovt)
        g.setColor(mx1)
        g.rectangle('fill',vx,0,vrw,rh)
        
        local ch2 = v.borderHoverColor or {.5,.5,.5,.8}
        local cb2 = v.borderColor or {.5,.5,.5,.8}
        local mx2 = mixColor(ch1,cb1,v.hovt)
        g.setColor(mx2)
        g.setLineWidth(2)
        g.rectangle('line',vx,0,vrw,rh)
        
        g.setColor(v.textColor or {1,1,1})
        g.print(t,tx,mh)
        
        try = try+rh+ph
        g.origin()
        g.translate(trx,try)
      end
      g.origin()
      
    end
  elseif game.state[2]=='serverBrowser' then
    g.push()
      g.clear(1,0,0)
      g.setColor(0,0,0)
      g.scale(23)
      g.print('TODO')
    g.pop()
  end
  
  do --FPS/Info
    g.setFont(defaultFont)
    g.setColor(1,1,1)
    local info
    if game.config.debug.enableDebugInfo then
      g.setColor(1,0,0)
      info = '[Debug Info ON]'
    end
    g.print(F('%s FPS %s',love.timer.getFPS(),info or ''))
  end
end

function menu.update(dt) end