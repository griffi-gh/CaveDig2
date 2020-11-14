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