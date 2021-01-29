gen={}

local function setTile(c,x,y,t,d)
  if not c[x] then c[x] = {} end
  if not c[x][y] then c[x][y] = {} end
  if not c[x][y].tile then c[x][y].tile = {} end
  c[x][y].tile.id = t
  c[x][y].tile.data = data or {}
end

local function sum(t)
  local sum = 0
  for i,v in ipairs(t) do
    sum = sum+v
  end
  return sum
end
local function avg(t)
  return sum(t)/#t
end
local function noise(x,s,m,u)
  return love.math.noise(x/s,u)*m
end
local function mnoise(x,gs,seed)
  return avg{
    noise(x,gs*1 ,1.00,seed),
    noise(x,gs*2 ,0.50,seed),
    noise(x,gs*4 ,0.25,seed),
    noise(x,gs*8 ,0.13,seed),
    noise(x,gs*16,0.06,seed),
    noise(x,gs*32,0.03,seed),
  }
end

function gen.genChunk(w,x,y)
  local seed = w.seed or 0
  local cs = w.chunkSize
  local d = {}
  --
  local terrh = {}
  for i=1,w.chunkSize do
    local lx = i+cs*(x-1)
    local gs,gm = 8,32--32,35
    terrh[i] = math.floor(mnoise(lx,gs,seed)*gm)
  end
  --
  for cy=1,cs do
    for cx=1,cs do
      local th = terrh[cx]
      local wx,wy = cx+(x-1)*cs,cy+(y-1)*cs
      local t = 1
      if wy>th then
        t = 3
      elseif wy==th then
        t = 2
      end
      setTile(d,cx,cy,t)
    end
  end
  --
  return {
    x = x,
    y = y,
    data = d
  } 
end