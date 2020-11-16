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
      background = love.graphics.newImage('res/dirt.png'),
      background_quad = nil,
      scrSpeed = 1,
    },
    worlds = {
      buthl = {},
      backhl = 0
    },
    main = {
      logo = 'MAIN MENU',
      buttons = {
        {
          text = 'Singleplayer',
          action = function() 
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
  local mdr = love.mouse.isDown(1)
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
      local f = menu.var.font[100]
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
      local f = menu.var.font[20]
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
    local bph = 100
    local gm = 10 --margin
    local pad = 15 --padding
    local worlds = save.enumerateWorlds()
    local bw,bh = w-gm*2,h-gm*2 --bgbox w/h
    
    --bg box
    g.setColor(.15,.15,.15,.5)
    g.rectangle('fill',gm,gm,bw,bh)
    g.setLineWidth(2)
    g.rectangle('line',gm,gm,bw,bh)
    
    --"logo"
    local tf = menu.var.font[60]
    g.setFont(tf)
    g.setColor(1,1,1)
    local titleh = tf:getHeight()+pad
    local ttxt = 'Worlds'
    g.print(
      ttxt,
      math.floor((w-tf:getWidth(ttxt))/2),
      pad+gm
    )
    
    
    local corner = pad+gm
    local backs1,backs2 = 30,100
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
    local backPoly = {
      backx+backs1,backy,
      backx,backy+backs1/2,
      backx+backs1,backy+backs1,
      backx+backs1+backs2,backy+backs1,
      backx+backs1+backs2,backy
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
    g.setLineWidth(3)
    g.polygon('line',backPoly)
    g.setLineWidth(1)
    local bfont = menu.var.font[20]
    local bktxt = 'BACK'
    g.setFont(bfont)
    g.setColor(1,1,1)
    g.print(
      bktxt,
      math.floor(backx+backs1+(backs2-bfont:getWidth(bktxt))/2),
      math.floor(backy+(backs1-bfont:getHeight())/2)
    )
    
    local ipad = 5 --cards padding
    local cspc = 10 -- cards dist
    local f = menu.var.font[30] --World name font
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
          world,player = save.loadWorld(v,player)
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