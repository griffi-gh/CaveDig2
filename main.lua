bitser = require'lib.bitser'
Camera = require'lib.camera'

require'save'
require'gen'
require'thr'

local F = string.format

game = {
  config = {
    ldist = 1,
    debug = {
      enableZ = true,
      drawChunkBorders = true,
      enableDebugInfo = true,
    },
    thread = { --experimental
      enable = true,
      waitForThreads = true,
      multithreadSave = true, 
      multithreadLoad = true,
    },
  },
  playerSize = {
    32,32
  }
}
world  = {
  name = 'World',
  chunks = {},
  chunkSize = 16,
  tileSize = 32,
  compression = true
}
player = {
  name = 'Player',
  x = 0,
  y = 0,
}
obj = {
  [0] = {
    type = 'uknown',
    name = '???',
    texture = love.graphics.newImage('res/err.png'),
    color = {0,0,0}
  },
  {
    type = 'floor',
    name = 'Grass (Floor)',
    texture = love.graphics.newImage('res/grass.png'),
    color = {1,.1,.1}
  },
  {
    type = 'floor',
    name = 'Dirt (Floor)',
    texture = love.graphics.newImage('res/dirt.png'),
    color = {.25,.16,.08}
  },
}

function love.quit()
  love.window.close()
  if game.config.thread.enable then
    love.thread.getChannel('saveThread_quit'):supply(true)
  end
  save.saveWorld(world,player)
end

local function saveChnk(v)
  if game.config.thread.multithreadSave then 
    love.thread.getChannel('unload'):push({world.name,v,world.compression})
  else
    save.saveChunk(world,v)
  end
end

--[[local function loadChnk(cx,cy)
  if save.chunkExists(world,cx,cy) then
    if game.config.thread.multithreadLoad then
      love.thread.getChannel('loadRequests'):push{world.name,cx,cy,world.compression}
    else
      c = save.loadChunk(world,cx,cy)
    end
  end
end]]

function love.keypressed(k)
  if k=='k' then
    save.saveWorld(world,player)
  elseif k=='l' then
    world,player = save.loadWorld(w,p)
  end
end

function love.load(args)
  --love.window.setVSync(0)
  camera = Camera(player.x,player.y)
  camera:setFollowStyle('NO_DEADZONE')
  if game.config.thread.enable then
    gSaveThread = startSaveThread() 
  end
end

function love.update(dt)
  local isd = love.keyboard.isDown
  local sp = 3
  local spd = sp*dt*60
  if isd('left') then
    player.x=player.x-spd
  end
  if isd('right') then
    player.x=player.x+spd
  end
  if isd('up') then
    player.y=player.y-spd
  end
  if isd('down') then
    player.y=player.y+spd
  end
  
  camera:follow(player.x+game.playerSize[1],player.y+game.playerSize[2])
  camera:update(dt)
  
  local cs  = world.chunkSize * world.tileSize
  local ldist = math.floor(game.config.ldist)
  
  local dif = {
    (playerChunk or {})[1],
    (playerChunk or {})[2]
  }
  _G.playerChunk = {
    math.floor((player.x+game.playerSize[1]/2)/cs)+1,
    math.floor((player.y+game.playerSize[2]/2)/cs)+1,
  }
  
  local p = love.thread.getChannel('loadReturn'):pop()
  if p then
    table.insert(world.chunks,p)
  end
  
  if game.loadChunks or dif[1]~=playerChunk[1] or dif[2]~=playerChunk[2] then
    
    game.loadChunks = false
    
    if game.config.thread.waitForThreads then
      while (
        love.thread.getChannel('unload'):getCount()>0 
        or
        love.thread.getChannel('loadRequests'):getCount()>0 
      ) do end
    end
  
    local bkt = {}
    for i=#world.chunks,1,-1 do
      local v = world.chunks[i]
      local d = math.max(
        math.ceil(math.abs(v.x-playerChunk[1])),
        math.ceil(math.abs(v.y-playerChunk[2]))
      )
      if d>ldist then
        saveChnk(v)
        table.remove(world.chunks,i)
      else
        local s = F('%s_%s',v.x,v.y)
        if not bkt[s]==nil then
          table.remove(world.chunks,i)
          print'[Warning] Overlapping Chunk!'
        end
        --assert(bkt[s]==nil, 'Overlapping chunks!')
        bkt[s] = v
      end
    end
    for ry=-ldist,ldist do
      for rx=-ldist,ldist do
        local cx,cy = rx+playerChunk[1],ry+playerChunk[2]
        local v = bkt[F('%s_%s',cx,cy)]
        if v==nil then
          local c
          if save.chunkExists(world,cx,cy) then
            if game.config.thread.multithreadLoad then
              love.thread.getChannel('loadRequests'):push{world.name,cx,cy,world.compression}
            else
              c = save.loadChunk(world,cx,cy)
            end
          else
            c = gen.genChunk(world,cx,cy)
          end
          if c then
            table.insert(world.chunks,c)
          end
        end
      end
    end
  end
end

function love.draw()
  local g = love.graphics
  g.setColor(1,1,1)
  local w,h = g.getDimensions()
  local chs = world.chunkSize*world.tileSize
  local uldist = game.config.uldist
  if game.config.debug.enableZ and love.keyboard.isDown('z') then
    g.translate(w/3,h/3)
    g.scale(.25)
  end
  camera:attach()
    for cid,ch in ipairs(world.chunks) do
      local chox,choy = chs*(ch.x-1), chs*(ch.y-1)
      local cchox,cchoy = camera:toCameraCoords(chox,choy)
      do
        for y=1,world.chunkSize do
          for x=1,world.chunkSize do
            local xr = ch.data[x]
            if xr then
              local v = xr[y]
              if v then
                local e = obj[0]
                do
                  local fl = obj[v.floor.id]
                  local t
                  if fl then
                    t = fl.texture
                  else
                    t = obj[0].texture
                  end
                  local fx,fy   = chox+(x-1)*world.tileSize,choy+(y-1)*world.tileSize
                  local cfx,cfy = camera:toCameraCoords(fx,fy)
                  if cfx>=-world.tileSize and cfy>=-world.tileSize and cfx<=w and cfy<=h then
                    g.draw(t,fx,fy)
                  end
                end
              end
            end
          end
        end
        if game.config.debug.drawChunkBorders then
          g.print('CHUNK'..ch.x..'_'..ch.y..' id:'..cid,chox+2,choy+2)
          g.rectangle('line',chox,choy,chs,chs)
        end
      end
    end
    g.rectangle('line',player.x,player.y,unpack(game.playerSize))
  camera:detach()
  if game.config.debug.enableDebugInfo then
    g.print(
      string.format(
        '%s FPS\n%s chunks loaded\n%s/%s in queue (save/load) \nPlayer in chunk: %s_%s\nCompression %s',
        love.timer.getFPS(),
        #world.chunks,
        love.thread.getChannel('unload'):getCount(),
        love.thread.getChannel('loadRequests'):getCount(),
        playerChunk[1],playerChunk[2],
        (world.compression and 'Enabled') or 'Disabled'
      )
    )
  end
end