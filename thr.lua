function startSaveThread()
  local saveThread = love.thread.newThread(
    [[
      require'love.timer'
      bitser = require'lib.bitser'
      require'defaults'
      require'save'
      
      local q = love.thread.getChannel('saveThread_quit')
      local u = love.thread.getChannel('unload')
      local l = love.thread.getChannel('loadRequests')
      local o = love.thread.getChannel('loadReturn')
      
      while true do
        local v = u:pop()
        if v then
          save.saveChunk(unpack(v))
        elseif q:pop() then
          break
        else
          local v2= l:pop()
          if v2 then
            o:push(save.loadChunk(unpack(v2)))
          else
            love.timer.sleep(1/30)
          end
        end
      end
    ]]
  )
  saveThread:start()
  return saveThread
end