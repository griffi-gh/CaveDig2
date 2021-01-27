--TODO

inputui = {
  mt = {
    __index = {
      show = function(self)
        self.shown = true
      end,
      hide = function(self)
        self.shown = false
      end,
      preUpdate = function(self)
        if self.shown then
          game.blockInput.m1 = true
        end
      end,
      draw = function(self)
        if self.shown then
          game.blockInput.m1 = true
          local g = love.graphics
          local w,h = g.getDimensions()
          local mw = math.max(
            self.titleFont:getWidth(self.title),
            self.descFont:getWidth(self.desc)
          )
          g.rectangle('fill',w/2,h/2,mw,mw)
        end
      end
    }
  }
}

function inputui.input(title,desc,callback,titleFont,descFont)
  return setmetatable(
    {
      title = title or 'Input',
      desc = desc or 'No decription',
      call = callback,
      titleFont = titleFont or fonts[20],
      descFont = titleFont or fonts[14],
      shown = false,
    },
    inputui.mt
  )
end
