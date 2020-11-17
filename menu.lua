local F = string.format

menu = {
  var = {
    font = {
      [20] = love.graphics.newFont(20), 
      [30] = love.graphics.newFont(30), 
      [60] = love.graphics.newFont(60), 
      [100] = love.graphics.newFont(100),
    },
    bg = {
      background = love.graphics.newImage('res/32/dirt.png'),
      background_quad = nil,
      scrSpeed = 1,
    },
    worlds = {
      worlds = nil,
      buthl = {},
      backhl = 0,
      newhl = 0 ,
    },
    main = {
      logo = 'MAIN MENU',
      buttons = {
        {
          text = 'Singleplayer',
          action = function() 
            menu.var.worlds.worlds = save.enumerateWorlds()
            game.switchState{'menu','worlds'} 
            --game.switchState{'game'} 
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
  menu.var.bg.background:setWrap("repeat", "repeat")
  local iw,ih = menu.var.bg.background:getDimensions()
  menu.var.bg.background_quad = love.graphics.newQuad(
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
  local mdr = love.mouse.isDown(1) and not(game.blockInput.m1)
  local md = mdr and not mdp
  local md2 = mdp and not mdr
  mdp = mdr
  
  do --background
    local var = menu.var.bg
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
  
  local hf = .1*love.timer.getDelta()*60 --Animation Speed
  
  if game.state[2]=='main' then
    local var = menu.var.main
    do --logo
      local f = fonts[100]
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
      local f = fonts[20]
      local fh = f:getHeight()
      local but = var.buttons
      g.setFont(f)
      
      local maxw = 0
      for i,v in ipairs(but) do
        maxw = math.max(maxw, f:getWidth(v.text))
      end
      
      local menuy = h/2
      local ph = 4
      local mw,mh = 8,3
      local minmw = 2 --for animations
      local cround = 4 --rounded corners
      g.origin()
      
      local trx,try = w/2,menuy+ph
      g.translate(trx,try)
      for i,v in ipairs(but) do
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
        if h then --Hover animation
          v.hovt = math.min(1,v.hovt+hf)
          if v.action and md2 then
            v:action(i)
          end
        else
          v.hovt = math.max(0,v.hovt-hf)
        end
        if mdr and h then --Hold Animation
          v.clkt = math.min(1,v.clkt+hf*4)
        else
          v.clkt = math.max(0,v.clkt-hf)
        end
        local vrw = rw-v.clkt*(mw-minmw)*2 --Visual width
        local vx = x+v.clkt*(mw-minmw) --Visual X
        --
        local ch1 = v.bgHoverColor or {.6,.6,.6,.8}
        local cb1 = v.bgColor or {0,0,0,.65}
        local mx1 = mixColor(ch1,cb1,v.hovt)
        g.setColor(mx1)
        g.rectangle('fill',vx,0,vrw,rh,cround)
        
        local ch2 = v.borderHoverColor or {.5,.5,.5,.8}
        local cb2 = v.borderColor or {.5,.5,.5,.8}
        local mx2 = mixColor(ch1,cb1,v.hovt)
        g.setColor(mx2)
        g.setLineWidth(2)
        g.rectangle('line',vx,0,vrw,rh,cround)
        
        g.setColor(v.textColor or {1,1,1})
        g.print(t,tx,mh)
        
        try = try+rh+ph
        g.origin()
        g.translate(trx,try)
      end
      g.origin()
      
    end
  elseif game.state[2]=='worlds' then
    local var = menu.var.worlds
    local worlds = var.worlds
    local bph = 100
    local gm = 10 --margin
    local pad = 15 --padding
    local bw,bh = w-gm*2,h-gm*2 --bgbox w/h
    
    --bg box
    g.setColor(.15,.15,.15,.5)
    g.rectangle('fill',gm,gm,bw,bh)
    g.setLineWidth(2)
    g.rectangle('line',gm,gm,bw,bh)
    
    local tf = fonts[60] --load logo font
    
    --back button
    local bpad = 20
    local corner = pad+gm
    local font20 = fonts[20]
    local bktxt = 'BACK'
    local backs1,backs2 = 30,font20:getWidth(bktxt)+bpad
    local backx,backy = corner+2,corner+(tf:getHeight()-backs1)/2
    local backh = mx>backx and my>backy and mx<backx+backs1+backs2 and my<backy+backs1
    if backh then
      var.backhl = math.min(1,var.backhl+hf)
      if md2 then
        game.switchState{'menu','main'}
        var.backhl = 0
      end
    else
      var.backhl = math.max(0,var.backhl-hf)
    end
    local vbackx = backx - var.backhl*10
    local vbacks2 = backs2 + var.backhl*10
    local backPoly = {
      vbackx+backs1,backy,
      vbackx,math.floor(backy+backs1/2)+1,
      vbackx+backs1,backy+backs1,
      vbackx+backs1+vbacks2,backy+backs1,
      vbackx+backs1+vbacks2,backy
    }
    g.setColor(
      mixColor(
        {1,0,0,.8},
        {.9,.1,.1,.5},
        var.backhl
      )
    )
    g.polygon('fill',backPoly)
    g.setColor(.9,.1,.1,1)
    g.setLineWidth(2)
    g.polygon('line',backPoly)
    g.setFont(font20)
    g.setColor(1,1,1)
    g.print(
      bktxt,
      math.floor(vbackx+backs1+(vbacks2-font20:getWidth(bktxt))/2),
      math.floor(backy+(backs1-font20:getHeight())/2)
    )
    local backtw = backx+backs1+backs2
    
    local newtxt = 'NEW WORLD'
    local newtxtw = font20:getWidth(newtxt)
    local newx,newy = backtw+2,backy
    local neww,newh = newtxtw+bpad,backs1
    local newhld = mx>newx and my>newy and mx<newx+neww and my<newy+newh
    if newhld then
      var.newhl = math.min(1,var.newhl+hf)
      if md2 then
        love.filesystem.createDirectory(
          save.getWorldDirectory(
            'NewWorld'..love.math.random(100000,999999)
          )
        )
        var.worlds = save.enumerateWorlds()
      end
    else
      var.newhl = math.max(0,var.newhl-hf)
    end
    g.setColor(
      mixColor(
        {0,.8,0},
        {.1,.75,.1,.5},
        var.newhl
      )
    )
    g.rectangle('fill',newx,newy,neww,newh)
    g.setColor(.1,.75,.1,1)
    g.rectangle('line',newx,newy,neww,newh)
    g.setColor(1,1,1)
    g.print(
      newtxt,
      math.floor(newx+neww/2-newtxtw/2),
      math.floor(newy+newh/2-font20:getHeight()/2)
    )
    
    g.setLineWidth(1)
    
    --"logo"
    g.setFont(tf)
    g.setColor(1,1,1)
    local titleh = tf:getHeight()+pad
    local ttxt = 'Worlds'
    g.print(
      ttxt,
      math.floor((w-tf:getWidth(ttxt)+backtw+neww)/2),
      pad+gm
    )
    
    local ipad = 5 --cards padding
    local cspc = 10 -- cards dist
    local f = fonts[30] --World name font
    g.setFont(f)
    
    local trx,try = gm+pad,gm+pad+titleh
    g.origin()
    g.translate(trx,try)
    for i,v in ipairs(worlds) do
      local cw,ch = bw-pad*2,f:getHeight()+ipad*2 
      
      g.setColor(.1,.1,.1,1)
      g.rectangle('fill',0,0,cw,ch,8,nil,48) --bg rect
      
      g.setColor(1,1,1) --World Name
      g.print(v,ipad,ipad)
      
      local plbx,plby,plbw,plbh = cw-ch-ipad+ipad*2,ipad,ch-ipad*2,ch-ipad*2
      local ph = mx>plbx+trx and mx<plbx+plbw+trx and my>plby+try and my<plby+plbh+try
      local hlt = var.buthl
      hlt[i] = hlt[i] or 0
      if ph then
        hlt[i]=math.min(1,hlt[i]+hf)
        if md2 then
          world,player = save.loadWorld(v,player,true)
          game.switchState{'game'}
        end
      else
        hlt[i]=math.max(0,hlt[i]-hf)
      end
      g.setColor(
        mixColor(
          {.1,.6,.1},
          {0, .8, 0},
          hlt[i]
        )
      )
      g.rectangle('fill',plbx,plby,plbw,plbh,5)
      local trpad = 4 --triangle padding
      g.setColor(0,.4,0,.5)
      g.polygon(
        'fill',
        plbx+plbw-trpad,plbh/2+trpad,
        plbx+trpad,plby+trpad,
        plbx+trpad,plby+plbh-trpad
      )
      
      try = try+ch+cspc
      g.origin()
      g.translate(trx,try)
    end
    g.origin()
    
    --[[bottom box
    g.setColor(.1,.1,.1,.4)
    g.rectangle('fill',gm,h-bph-gm,w-gm*2,bph)]]
  elseif game.state[2]=='serverBrowser' then
    
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

function menu.update(dt)
  if game.config.debug.spaceToPlay and love.keyboard.isDown'space' then
    game.switchState{'game'}
    return
  end
end