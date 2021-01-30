physics = {}

function physics.new(w,p)
  local obj = {}
  obj.cdworld = w
  obj.cdplayer = p
  obj.world = wf.newWorld(0,0,true)
  obj.world:setGravity(0,512)
  obj.world:addCollisionClass(
    'player',
    {ignores = {'player','entity-dynamic'}}
  )
  obj.world:addCollisionClass(
    'block',
    {ignores = {'block','entity-static'}}
  )
  obj.world:addCollisionClass(
    'entity-dynamic', --dynamic entity without player/entity collision
    {ignores = {'entity-dynamic','player'}}
  ) 
  obj.world:addCollisionClass(
    'entity-static', --static entity with player/entity collision
    {ignores = {'entity-static','block'}}
  )
  obj.obj = {blocks = {}}
  
  function obj.update(dt)
    obj.world:update(dt)
  end
  
  function physics.cleanup()
    for i=#obj.obj,1,-1 do
      
    end
  end
  
  function obj.calcChunk(id,ch)
    local chs = w.chunkSize
    local chx,chy = chs*(ch.x-1),chs*(ch.y-1)
    for y=1,world.chunkSize do
      for x=1,world.chunkSize do
        local xr = ch.data[x]
        if xr then
          local v = xr[y]
          local tile = obj[v.tile.id]
          if v and tile.collision then
            local shp = tile.collisionShape
            local blx,bly = chx+(x-1)*world.tileSize,chy+(y-1)*world.tileSize
            local block
            if shp then
              -- **NOT TESTED** --
              block = obj.world:newPolygonCollider(shp) 
              block:setPosition(blx,bly) 
              -- **NOT TESTED** --
            else
              block = obj.world:newRectangleCollider(blx,bly,world.tileSize,world.tileSize)
            end
            block:setType('static')
            block:setCollisionClass('block')
            table.insert(obj.obj.blocks,
              {
                collider = block,
                chunk = {
                  x = ch.x,
                  y = ch.y
                }
              }
            )
          end
        end
      end
    end
  end
  
  function physics.calcChunks()
    physics.cleanup()
    for id,chnk in ipairs(world.chunks) do
      physics.calcChunk(id,chnk)
    end
  end 
end