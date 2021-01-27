bitser = require'lib.bitser'
Camera = require'lib.camera'
socket = require'socket'

require'fonts'
require'fn'
require'defaults'
require'inputui'
require'save'
require'gen'
require'thr'
require'multiplayer'
require'menu'

love.math.setRandomSeed(love.math.random(1,2432432434534))

local F = string.format

game = {
  config = {
    ldist = 1,
    fpsCounter=true,
    graphics = {
      noFloorTextures = false,
    },
    debug = {
      enableZoom = true,
      drawChunkBorders = true,
      enableDebugInfo = true,
      debugDrawDirt = true,
      spaceToPlay = true,
    },
    thread = { --experimental
      enable = true,
      waitForThreads = false,
      multithreadSave = true,
      multithreadLoad = true,
      receiveMultiple = true,
      deduplicateChunks = true,
      runUnloader = true,
    }
  },
  playerSize = {
    32,32
  },
  state = {'menu','main'},
  blockInput = {},
}

world = worldDefualt()
player = playerDefault()

obj = {
  [0] = {
    type = 'unknown',
    name = '???',
    texture = love.graphics.newImage('res/32/err.png'),
    color = {0,0,0}
  },
   {
    type = 'tile',
    name = 'air',
    texture = love.graphics.newImage('res/32/air.png'),
    color = {0,0,0}
  },
  {
    type = 'tile',
    name = 'Grass (tile)',
    texture = love.graphics.newImage('res/32/grass.png'),
    color = {.3,.65,.1}
  },
  {
    type = 'tile',
    name = 'Dirt (tile)',
    texture = love.graphics.newImage('res/32/dirt.png'),
    color = {.25,.16,.08}
  },
  {
    type = 'tile',
    name = 'Stone (tile)',
    texture = love.graphics.newImage('res/32/stone.png'),
    color = {.25,.16,.08}
  },
  {
    type = 'tile',
    name = 'Log (tile)',
    texture = love.graphics.newImage('res/32/wood.png'),
    color = {.25,.16,.08}
  },
  {
    type = 'tile',
    name = 'Leaves (tile)',
    texture = love.graphics.newImage('res/32/leaves.png'),
    color = {.25,.16,.08}
  },
}
for i,v in ipairs(obj) do
  if v.texture then
    v.texture:setFilter('nearest','nearest',1)
  end
end

function game.switchState(new)
  game.nextState = new
end

function love.quit()
  love.window.close()
  if game.config.thread.enable then
    love.thread.getChannel('saveThread_quit'):supply(true)
  end
  if game.state[1]=='game' then
    save.saveWorld(world,player)
  end
end

local function saveChnk(v)
  if game.config.thread.enable and game.config.thread.multithreadSave then
    love.thread.getChannel('unload'):push({world.name,v,world.compression})
  else
    save.saveChunk(world,v)
  end
end

local function loadChnk(cx,cy)
  if save.chunkExists(world,cx,cy) then
    if game.config.thread.enable and game.config.thread.multithreadLoad then
      love.thread.getChannel('loadRequests'):push{world.name,cx,cy,world.compression}
    else
      return save.loadChunk(world,cx,cy)
    end
  end
end

function deduplicateChunks()
  local seen = {}
  for i=#world.chunks,1,-1 do
    local v = world.chunks[i]
    local j = F('%s!%s',v.x,v.y)
    if seen[j] then
      table.remove(world.chunks,i)
    end
    seen[j]=true
  end
end

function chunkLoader(playerChunk,force,unloadOnly)
  playerChunk = playerChunk or _G.playerChunk -- **TODO** remove this
  local cs  = world.chunkSize * world.tileSize
  local ldist = math.floor(game.config.ldist)

  if game.config.thread.enable and not(force) and game.config.thread.waitForThreads then
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
      bkt[s] = v
    end
  end
  if not unloadOnly then
    for ry=-ldist,ldist do
      for rx=-ldist,ldist do
        local cx,cy = rx+playerChunk[1],ry+playerChunk[2]
        local v = bkt[F('%s_%s',cx,cy)]
        if v==nil then
          local c
          if save.chunkExists(world,cx,cy) then
            c = loadChnk(cx,cy)
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

function love.keypressed(k)
  if k=='k' then
    save.saveWorld(world,player)
  elseif k=='l' then
    world,player = save.loadWorld(w,p)
  end
end

function love.load(args)
  love.window.setVSync(0)
  camera = Camera(player.x,player.y)
  camera:setFollowStyle('NO_DEADZONE')
  if game.config.thread.enable then
    gSaveThread = startSaveThread()
  end
end

function love.update(dt)
  game.blockInput = {}
  if game.nextState then
    game.state = game.nextState
    game.nextState = nil
  end
  if game.state[1]=='menu' then
    menu.update(dt)
  elseif game.state[1]=='game' then
    local isd = love.keyboard.isDown
    local sp = 4
    local spd = math.min(sp*60,sp*dt*60)
    if isd'left' or isd'a' then
      player.x=player.x-spd
    end
    if isd'right' or isd'd' then
      player.x=player.x+spd
    end
    if isd'up' or isd'w' then
      player.y=player.y-spd
    end
    if isd'down' or isd's' then
      player.y=player.y+spd
    end

    if game.config.debug.debugDrawDirt then
      if love.mouse.isDown(1) then
        for i,v in ipairs(world.chunks) do
          if v.x==playerChunk[1] and v.y==playerChunk[2] then
            local mx,my = love.mouse.getPosition()
            local lx,ly = math.floor(mx/world.tileSize+v.x/3-1),math.floor(my/world.tileSize+v.y/3)
            if v.data[lx] and v.data[lx][ly] then
              v.data[lx][ly].tile.id = 2
            end
            break
          end
        end
      end
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

    if game.config.thread.enable and game.config.thread.multithreadLoad then
      local loaded = false
      while true do
        local p = love.thread.getChannel('loadReturn'):pop()
        if p then
          table.insert(world.chunks,p)
          loaded = true
          if not game.config.thread.receiveMultiple then
            break
          end
        else
          break
        end
      end
      if loaded then
        if game.config.thread.deduplicateChunks then
          deduplicateChunks()
        end
        if game.config.thread.runUnloader then
          chunkLoader(nil,true,true)
        end
      end
    end

    if dif[1]~=playerChunk[1] or dif[2]~=playerChunk[2] then
      chunkLoader()
    end
  end
end

function love.draw()
  --locals
  local world,player,game,obj = world,player,game,obj
  local g = love.graphics
  local draw = g.draw
  --
  love.graphics.setBackgroundColor(0.5, 0.5, 1)
  g.clear()
  g.setColor(1,1,1)
  local w,h = g.getDimensions()

  if game.config.debug.enableZoom and love.keyboard.isDown('z') then
    g.translate(w/3,h/3)
    g.scale(.25)
  end

  if game.state[1]=='menu' then
    g.push()
      menu.draw()
    g.pop()
  elseif game.state[1]=='game' then
    local chs = world.chunkSize*world.tileSize
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
                    local fl = obj[v.tile.id]
                    local t
                    if fl then
                      t = fl.texture
                    else
                      t = obj[0].texture
                    end
                    local fx,fy   = chox+(x-1)*world.tileSize,choy+(y-1)*world.tileSize
                    local cfx,cfy = camera:toCameraCoords(fx,fy)
                    if cfx>=-world.tileSize and cfy>=-world.tileSize and cfx<=w and cfy<=h then
                      if game.config.graphics.noFloorTextures then
                        g.setColor(fl.color)
                        g.rectangle('fill',fx,fy,world.tileSize,world.tileSize)
                      else
                        local sx,sy = t:getDimensions()
                        draw(
                          t,fx,fy,0,
                          (fl.noScale and 1) or world.tileSize/sx,
                          (fl.noScale and 1) or world.tileSize/sy
                        )
                      end
                    end
                  end
                end
              end
            end
          end
          if game.config.debug.drawChunkBorders then
            g.setColor(1,1,1)
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
          '%s FPS\n%s chunks loaded\n%s/%s/%s in queue (save/load/recv) \nPlayer in chunk: %g_%g\nPlayer x:%g\ny:%g\nCompression %s',
          love.timer.getFPS(),
          #world.chunks,
          love.thread.getChannel('unload'):getCount(),
          love.thread.getChannel('loadRequests'):getCount(),
          love.thread.getChannel('loadReturn'):getCount(),
          playerChunk[1],playerChunk[2],
          player.x,player.y,
          (world.compression and 'Enabled') or 'Disabled'
        )
      )
    elseif game.config.fpsCounter then
      g.print(love.timer.getFPS()..' FPS')
    end
  end
end
