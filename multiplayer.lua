mp = {}

local con_={}
function con_:send(event,data)
  self.socket:send(
    bitser.dumps{
      e = event,
      d = datas,
      id = self.pid
    }
  )
end

function con_:reqChunk(cx,cy)
  con_:send('rch',{cx,cy})
end

function mp.connect(ip,port)
  port = port or 10174
  local con = {}
  setmetatable(con,{__index = con_})
  con.pid = love.math.random(0,999999999)
  con.socket = socket.udp()
  con.socket:settimeout(0)
  con.socket:setpeername(ip,port)
  con:send('connect')
  return con
end