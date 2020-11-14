gen = {}

function gen.genChunk(w,x,y)
  local d = {}
  for i = 1,world.chunkSize do
    d[i] = d[i] or {}
    for j = 1,world.chunkSize do
      d[i][j] = {
        floor={
          id=love.math.random(1,2)
        } 
      }
    end
  end
  return {
    x = x,
    y = y,
    data = d
  }
end
--[[
for i=-2,2,1 do
    for j=-2,2,1 do
      local d = {}
      for ii = 1,world.chunkSize do
        d[ii] = {}
        for jj = 1,world.chunkSize do
          d[ii][jj] = {
            floor={
              id=love.math.random(1,2)
            } 
          }
        end
      end
      table.insert(
        world.chunks,
        {
          x = i,
          y = j,
          data = d
        }
      )
    end
  end]]