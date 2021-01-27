gen = {}

local function setTile(c, x, y, t, ...)
    if not c[x] then
      c[x] = {}
    end
    if not c[x][y] then
      c[x][y] = {}
    end
    c[x][y] = {tile = {id = t, data = {...}}}
end

local terrh = 16
local upa = 5

function gen.genChunk(w, x, y)
  local curv = {}
  for i = 1, world.chunkSize do
    curv[i] = love.math.noise((i + world.chunkSize * x) / 64) * 16
  end
  local d = {}
  for i = 1, world.chunkSize do
    d[i] = d[i] or {}
    for j = 1, world.chunkSize do
      local ide =
        (world.chunkSize * y + j > curv[i] and world.chunkSize * y + j < curv[i] + 1 and 2 or
        world.chunkSize * y + j > curv[i] + 1 and world.chunkSize * y + j < curv[i] + 6 and 3 or
        world.chunkSize * y + j > curv[i] and 4 or
        1)
      if ide == 2 then
        upa = j
      end
      if not d[i][j] then
        d[i][j] = {
          tile = {
            id = ide,
            data = {}
          }
        }
        if love.math.noise((i + world.chunkSize * x) / 28, (j + world.chunkSize * y) / 28) * 32 > 25 and y > 1 then
          d[i][j] = {
            tile = {
              id = 1,
              data = {}
            }
          }
        end
        if love.math.noise((i + world.chunkSize * x) / 19, (j + world.chunkSize * y) / 128) * 38 > 35 and y < 3 then
          d[i][j] = {
            tile = {
              id = 1,
              data = {}
            }
          }
        end
      end
      --  upa = world.chunkSize*y + j > curv[i] and world.chunkSize*y + j < curv[i]+1 and j
      --  d[i][upa] = {tile={id=0}}
      --  error(upa)
      local th = love.math.random(3, 6)
      if
        (love.math.random(1, 10000) > 9800 and upa and (i > 0 and i < 16) and upa + th + 1 < 17 and d[i] and
          d[i][upa + 1] and
          d[i][upa + 1].tile and
          (d[i][upa + 1].tile.id == 2 or d[i][upa + 1].tile.id == 3))
       then
        for ii = 1, th - 1 do
          d[i][upa - ii] = {
            tile = {
              id = 5,
              data = {}
            }
          }
        end
        setTile(d, i, upa - th, 6)
        setTile(d, i + 1, upa - th, 6)
        setTile(d, i - 1, upa - th, 6)
        setTile(d, i, upa - th - 1, 6)
      end
    end
    terrh = curv[i]
  end
  return {
    x = x,
    y = y,
    data = d
  }
end
