physics = {
  obj = {
    blocks = {}
  }
}

function physics.newWorld()
  
end

function physics.update(dt)
  
end

function physics.calcChunks()
  for id,chnk in ipairs(world.chunks) do
    physics.calcChunk(id,chnk)
  end
end 

function physics.calcChunk(id,chnk)
  for y=1,world.chunkSize do
    for x=1,world.chunkSize do
      local xr = ch.data[x]
      if xr then
        local v = xr[y]
        if v then
          
        end
      end
    end
  end
end