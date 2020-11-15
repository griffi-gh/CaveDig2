menu = {
  var = {
    main = {
      buttons = {
        {
          text = 'Singleplayer',
          action = function() 
            --game.switchState{'menu','worlds'} 
            game.switchState{'game'} 
          end
        },
        {
          text = 'Multiplayer??!',
          action = function()
            game.switchState{'menu','servers'}
          end
        },
        {
          text = 'Exit',
          action = function()
            love.event.quit()
          end
        }
      }
    }
  }
}
  
function menu.draw()
  local g = love.graphics
  g.scale(8)
  g.print('PRESS SPACE!')
  if game.state[2]=='main' then
    for i,v in ipairs(menu.var.main.buttons) do
      
    end
  end
  g.origin()
end

function menu.update(dt)
  if love.keyboard.isDown('space') then
    game.switchState{'game'}
  end
end