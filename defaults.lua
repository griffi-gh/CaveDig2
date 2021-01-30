function worldDefualt(n,s)
  return {
    name = n or 'World',
    chunks = {},
    chunkSize = 16,
    tileSize = 32,
    compression = true,
    seed = s or love.math.random(0,999999),
    saveVersion = save.version or -1
  }
end

function playerDefault(n,sx,sy)
  return {
    name = n or 'Player',
    x = sx or 0,
    y = sy or 0,
  }
end 

function tileDefault(id,data)
  return {
    id = id or 1,
    data = data or {}
  }
end