pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- Gloabal functions

--Model
local pumpkin
local coins
local score
local blocks
local draw_bounding = false

function _init()
  score = 0

  pumpkin = {
    x=64,
    y=14,
    width=8,
    height=8,
    radius=4,
    speed=1,
    color=8,
    velocity_x=0,
    velocity_y=0,
    standing_on_block = false,
    draw = function (self)
      local x, y, w, h = self.x, self.y, self.width, self.height
      spr(4, self.x, self.y)
      draw_bounding_rect(self)
    end,
    update = function(self)
      -- apply friction
      self.velocity_x = mid(-3, self.velocity_x*0.2, 3)
      -- apply gravity
      self.velocity_y = mid(-3, self.velocity_y+0.1, 3)

      -- move the player with arrow keys
      if btn(1) then self.velocity_x = self.speed end
      if btn(0) then self.velocity_x = -self.speed end

      -- jump when z is pressed
      if btn(4) and self.standing_on_block then
        self.velocity_y = -3
      end

      -- apply velocity to speed
      self.x+= self.velocity_x
      self.y+= self.velocity_y

      --reset the jump switch
      self.standing_on_block = false
    end,
    check_coin_collisions = function(self, coin)
      if not coin.collected and overlap(self, coin) then
        coin.collected = true
        score+=1
      end
    end,
    check_block_collisions = function(self, block)
      local x, y, w, h = self.x, self.y, self.width, self.height
      local top_hitbox= {x=x+3,       y=y,    width=2, height=4}
      local bottom_hitbox= {x=x+3,    y=y+4,  width=2, height=4}
      local left_hitbox= {x=x,        y=y+3,  width=4, height=2}
      local right_hitbox= {x=x+4,     y=y+3,  width=4, height=2}
      -- printh(""..self.x..", "..self.y.." - " ..left_hitbox.x..", "..left_hitbox.y..", "..left_hitbox.width..", "..left_hitbox.height)

      if overlap(block, bottom_hitbox)then
        self.y = block.y-self.height
        self.standing_on_block = true
        if self.velocity_y > 0 then self.velocity_y = 0 end
      elseif overlap(block, left_hitbox)then
        self.x = block.x + block.width
        if self.velocity_x < 0 then self.velocity_x = 0 end
      elseif overlap(block, right_hitbox)then
        self.x = block.x - self.width
        if self.velocity_x > 0 then self.velocity_x = 0 end
      elseif overlap(block, top_hitbox)then
        self.y = block.y + block.height
        if self.velocity_y < 0 then self.velocity_y = 0 end
      end
    end
  }

  coins = {}
  for i = 1,3 do
    add(coins, create_coin(30+15*i, 80))
  end

  blocks = {}
  for i=1,15 do
    add(blocks, create_block(8*i, 90))
  end
  add(blocks, create_block(50, 50))
  add(blocks, create_block(80, 70))
  add(blocks, create_block(50, 82))
end

-- Game

function _update()
  pumpkin:update()
  for coin in all(coins) do
    coin:update()
    pumpkin:check_coin_collisions(coin)
  end
  for block in all(blocks) do
    block:update()
    pumpkin:check_block_collisions(block)
  end


end

function _draw()
  cls()
  pumpkin:draw()
  foreach(coins, function(coin) coin:draw() end)
  foreach(blocks, function(block) block:draw() end)
  print("score: "..score, 0,0,7 )
end


-- function create_coin(_x, _y)
--   return {x=_x, y=_y}
-- end

function create_coin(_x,_y)
  return {
    x=_x,
    y=_y,
    radius=3,
    height=6,
    width=6,
    collected=false,
    update = function() end,
    draw=function(self)
      if(not self.collected) then
        spr(7, self.x, self.y)
        -- draw_bounding_rect(self)
      end
    end
  }
end

function create_block(_x, _y)
  return {
    x = _x,
    y = _y,
    width = 8,
    height = 8,
    update = function(self)
    end,
    draw = function(self)
      spr(6, self.x, self.y)
      draw_bounding_rect(self)
    end
  }
end

-- global functions
function draw_bounding_circle(e)
  if draw_radius then
    circ(e.x+4, e.y+4, e.radius)
  end
end

function draw_bounding_rect(e)
  if draw_bounding then
    rect(e.x, e.y, e.x + e.width - 1, e.y + e.height-1, 8)
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
  local x1, y1, height1, width1 = e1.x, e1.y, e1.height, e1.width
  local x2, y2, height2, width2 = e2.x, e2.y, e2.height, e2.width
  return x1+width1 >= x2 and x1 <= x2+width2 and y1+height1 >= y2 and y1 <= y2+height2
end

function sqr(n) return n * n end

__gfx__
000000000000000000000000000000000000b0000000b00077777777000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000093b90000e3be007666666d0009aa000000000000000000000000000000000000000000000000000000000000000000
0070070000000000000000000000000099499494ee4ee4e47677776d009aaaa00000000000000000000000000000000000000000000000000000000000000000
0007700000000000000000000000000094999494e4eee4e476766d6d009aaaa00000000000000000000000000000000000000000000000000000000000000000
0007700000000000000000000000000094999499e4eee4ee76766d6d009aaaa00000000000000000000000000000000000000000000000000000000000000000
0070070000000000000000000000000094999499e4eee4ee76dddd6d009aaaa00000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000099499499ee4ee4ee7666666d0009aa000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000099449900ee44ee0dddddddd000000000000000000000000000000000000000000000000000000000000000000000000
