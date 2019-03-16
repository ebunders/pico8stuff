pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- Gloabal functions

--Model
local pumpkin
local coins
local score
local draw_radius = true

function _init()
  score = 0

  pumpkin = {
    x=64,
    y=64,
    width=8,
    height=8,
    radius=12,
    speed=1,
    color=8,
    draw = function (self)
      spr(4, self.x, self.y)
      draw_bounding_circle(self)
    end,
    update = function(self)
      if(btn(1)) then self.x+=self.speed end
      if(btn(0)) then self.x-=self.speed end
      if(btn(3)) then self.y+=self.speed end
      if(btn(2)) then self.y-=self.speed end
    end
  }

  coins = {
    create_coin(30,100),
    create_coin(50,80),
    create_coin(10,20),
    create_coin(100,50),
    create_coin(20,70)
  }
end

-- Game

function _update()
  pumpkin:update()

  for coin in all(coins) do
    if not coin.collected then
      coin:update()
      if circular_overlap(pumpkin, coin) then
        coin.collected = true
        score+=1
      end
    end
  end
end

function _draw()
  cls()
  pumpkin:draw()
  foreach(coins, function(coin) coin:draw() end)
  print("score: "..score, 0,0,7 )
end


-- function create_coin(_x, _y)
--   return {x=_x, y=_y}
-- end

function create_coin(_x,_y)
  return {
    x=_x,
    y=_y,
    radius=9,
    collected=false,
    update = function() end,
    draw=function(self)
      if(not self.collected) then
        spr(7, self.x, self.y)
        draw_bounding_circle(self)
      end
    end
  }
end

-- global functions
function draw_bounding_circle(e)
  if draw_radius then
    circ(e.x+4, e.y+4, e.radius)
  end
end

function circular_overlap(e1, e2)
  local dx = mid(-100, e1.x - e2.x, 100)
  local dy = mid(-100, e1.y - e2.y, 100)
  local tr = e1.radius + e2.radius
  -- local dist = sqrt(dx*dx+dy*dy)
  -- return dist < e1.radius + e2.radius
  return sqr(dx) + sqr(dy) < sqr(tr)
end

function overlap(e1, e2)
  local x1, y1, x2, y2 = e1.x, e1.y, e2.x, e2.y
  return x1+8 > x2 and x1 < x2+8 and y1+8 > y2 and y1 < y2+8
end

function sqr(n) return n * n end

__gfx__
000000000000000000000000000000000000b0000000b00000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000093b90000e3be00000000000009aa000000000000000000000000000000000000000000000000000000000000000000
0070070000000000000000000000000099499494ee4ee4e400000000009aaaa00000000000000000000000000000000000000000000000000000000000000000
0007700000000000000000000000000094999494e4eee4e400000000009aaaa00000000000000000000000000000000000000000000000000000000000000000
0007700000000000000000000000000094999499e4eee4ee00000000009aaaa00000000000000000000000000000000000000000000000000000000000000000
0070070000000000000000000000000094999499e4eee4ee00000000009aaaa00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000099499499ee4ee4ee000000000009aa000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000099449900ee44ee000000000000000000000000000000000000000000000000000000000000000000000000000000000
