function worldDefualt(n)
  return {
    name = n or'World',
    chunks = {},
    chunkSize = 16,
    tileSize = 32,
    compression = true
  }
end

function playerDefault(n)
  return {
    name = n or 'Player',
    x = 0,
    y = 0,
  }
end 