save = {}
local fs = love.filesystem
------------------
local function gname(w)
  if type(w)=='table' then w=w.name end
  return w
end
local function gcmp(w,cmp)
  local r = cmp or (type(w)=='table' and w.compression)
  if r==true then r = {} end
  return r
end
------------------
save.WorldsDirectory = 'Worlds/'

function save.enumerateWorlds()
  local d = save.WorldsDirectory
  local t = fs.getDirectoryItems(d)
  local r = {}
  for i,v in ipairs(t) do
    local l = string.format('%s/%s',d,v)
    if fs.getInfo(l,'directory') then
      r[#r+1] = v
    end
  end
  return r
end

function save.getWorldDirectory(w)
  return save.WorldsDirectory..gname(w)
end

function save.getChunkDirectory(w)
  return string.format('%s/Chunks',save.getWorldDirectory(w))
end

function save.getChunkFile(w,cx,cy)
  return string.format('%s/%s_%s.chnk',save.getChunkDirectory(w),cx,cy)
end

function save.getDataFile(w)
  return save.getWorldDirectory(w)..'/world.wdt'
end
------------------
function save.getPlayersDirectory(w)
  return string.format('%s/Players',save.getWorldDirectory(w))
end

function save.getPlayerFile(w,p)
  return string.format('%s/%s.plr',save.getPlayersDirectory(w),gname(p))
end
------------------

save.defaultCmpType = 'lz4'

function save.saveChunk(w,c,cmp)
  cmp = gcmp(w,cmp)
  fs.createDirectory(save.getChunkDirectory(w))
  local d = bitser.dumps(c)
  if cmp then
    local k,dd = pcall(love.data.compress,'string', cmp.type or save.defaultCmpType, d, cmp.level)
    if k then d = dd end
  end
  fs.write( 
    save.getChunkFile(w,c.x,c.y),
    d
  )
end

function save.loadChunk(w,x,y,cmp)
  cmp = gcmp(w,cmp)
  local f = fs.read(save.getChunkFile(w,x,y))
  if f~=nil then
    local d = f
    if cmp then
      local k,dd = pcall(love.data.decompress,'string', cmp.type or save.defaultCmpType ,d)
      if k then d = dd end
    end
    d = bitser.loads(d)
    assert(type(d)=='table','Failed to load Chunk Data')
    return d
  end
end

function save.saveAllChunks(w)
  for i,v in ipairs(w.chunks) do
    save.saveChunk(w,v)
  end
end

function save.chunkExists(w,x,y)
  return type(love.filesystem.getInfo(save.getChunkFile(w,x,y)))=='table'
end
------------------
function save.saveWorldData(w,p)
  local sd = {}
  for i,v in pairs(w) do
    if i~='chunks' and i~='name' then
      sd[i]=v
    end
  end
  local d = bitser.dumps(sd)
  local f = save.getDataFile(w)
  fs.write(f,d)
end

function save.loadWorldData(w)
  local f  = save.getDataFile(w)
  local r  = fs.read(f)
  local d  = bitser.loads(r)
  d.chunks = {} 
  d.name   = gname(w)
  return d
end
------------------
function save.savePlayerData(w,p)
  fs.createDirectory(save.getPlayersDirectory(w))
  local sd = {}
  for i,v in pairs(p) do
    if i~='name' then
      sd[i] = v
    end
  end
  fs.write(
    save.getPlayerFile(w,p),
    bitser.dumps(sd)
  )
end

function save.loadPlayerData(w,p)
  local t = bitser.loads(fs.read(save.getPlayerFile(w,p)))
  t.name = gname(p)
  return t
end
------------------
function save.saveWorld(w,p)
  save.savePlayerData(w,p)
  save.saveWorldData(w,p)
  save.saveAllChunks(w)
end

function save.loadWorld(w,p,ord)
  local lw,lp,e
  if fs.getInfo(save.getPlayerFile(w,p))then
    lp = save.loadPlayerData(w,p)
  elseif ord then
    lp = playerDefault(gname(p))
  end
  if fs.getInfo(save.getDataFile(w)) then
    lw = save.loadWorldData(w)
    e = true
  elseif ord then
    lw = worldDefualt(gname(w))
  end
  return lw,lp,e
end
------------------
save.defaultOptionsFile = 'game.options'

function save.saveOptions(x,o)
  x = x or save.defaultOptionsFile
  fs.write(x,biser.dumps(o))
end

function save.loadOptions(x)
  x = x or save.defaultOptionsFile
  local d = fs.read(x)
  if d then
    return bitser.loads(d) 
  end
end
------------------
