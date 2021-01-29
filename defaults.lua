function worldDefualt(n)
  return {
    name = n or'World',
    chunks = {},
    chunkSize = 16,
    tileSize = 32,
    compression = true,
    seed = love.math.random(0,999999)
  }
end

function playerDefault(n)
  return {
    name = n or 'Player',
    x = 0,
    y = 0,
  }
end 

function tileDefault(id)
  return {
    id = 1,
    data = {}
  }
end