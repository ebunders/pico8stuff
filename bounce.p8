pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--ideen:
-- als de bal een object raakt licht die even op
-- aan het begin van het spel wordt de court als animatie getekent.
local gravity=0.1
local score=0
local score_counter=0
local score_delay_counter_max=7
local score_delay_counter=score_delay_counter_max
local mode='start'
local play_mode = ''
local lives=3
local max_velocity=5

function init_score()
  score=0;
  score_counter=0
end

local court = {
  is_colliding=false,
  collision_counter=0,
  color=11,
  collision_color=8,
  lines = {
    {x1=3, y1=8, x2=3, y2=114},
    {x1= 124, y1=8, x2=124, y2=114},
    {x1=3, y1=8, x2=124, y2=8},
  },
  update= function(self)
    if self.is_colliding then
      self.collision_counter=5
      self.is_colliding=false
    elseif self.collision_counter>0 then
      self.collision_counter-=1
    end
  end,

  draw = function(self)
    local color = ((self.collision_counter>0) and self.collision_color or self.color)
    for l in all(self.lines) do
      line(l.x1, l.y1, l.x2, l.y2, color)
    end
  end
}

local pad = {
  x=52,
  y=120,
  w=30,
  h=6,
  velocity=0,
  friction=0.6,
  acceleration=1,
  max_velocity=5,

  update = function (self)

    self.velocity = reduce(self.velocity, self.friction)
  	if btn(0) and self.x > 3 then 	self.velocity-=self.acceleration end
  	if btn(1) and self.x < 127-(self.w+3) then self.velocity+=self.acceleration end
    self.x = mid(0, self.x+self.velocity, 127-self.w)
  end,

  draw = function (self)
    spr(1, self.x, self.y)
    spr(1, self.x+(self.w-8), self.y, 1,1, true, false)
    if(self.w > 16) then
      for l,c in pairs({[0]=7,[1]=13,[2]=13,[3]=13,[4]=5, [5]=6}) do
        line(self.x+8, self.y+l, self.x+(self.w-8), self.y+l, c)
      end
    end
  end
}

local ball


function init_ball()
  ball = {
    x=52,
    y=20,
    velocity_x=0,
    velocity_y=0,
    h=7,
    w=7,
    colliding=false,
    collisioin_color=0,

    calculate_velocity=function(self)
        return ((abs(self.velocity_x) + abs(self.velocity_y))/2)-0.1
    end,

    collide_pad = function(self)
      if overlap(self,pad) then
        if not self.colliding then sfx(1) end
        self.colliding = true
        self.y=pad.y-self.h
        self.velocity_y= -mid(0, self.velocity_y - pad.friction + abs(pad.velocity), max_velocity)
        self.velocity_x = -pad.velocity
      else
        self.colliding=false
      end
    end,

	  -- ball hits the court
    collide_court = function(self)
      if self.y<=8 then
        self.velocity_y= -self.velocity_y
        self.y=8
        self:handle_collision()
      end
      if self.x<=3 then
        self.velocity_x = -self.velocity_x
        self.x=4
        self:handle_collision()
      end
      if self.x>=(124-self.w) then
        self.velocity_x= -self.velocity_x
        self.x=123-self.w
        self:handle_collision()
      end
    end,

    handle_collision=function(self)
      court.is_colliding=true
      local v=self:calculate_velocity()
      court.collision_color=velocity_color(v)
      score+=flr(v)
    end,

    update = function(self)
    	if play_mode == 'new_ball' then
    		-- start new ball
    		if btn(5) then play_mode=''; sfx(0) end
    	else
    		--move the ball
	      self:collide_court()
	      self:collide_pad()

	      -- update the pad velocity and position
	      self.velocity_y = self.velocity_y+gravity
	      self.y+=self.velocity_y
	      self.x+=self.velocity_x

	      -- is the ball lost?
			  if self.y > 127 then
		      init_ball()
		      lives-=1
		      if lives>0 then
		       	play_mode="new_ball"
            sfx(2)
		      else
		       	mode="end"
            sfx(4)
					end
	    	end
    	end
	  end,

	  draw= function(self)
	  	if play_mode == "new_ball" then
			  print ("press (x) for new ball", 20, 30)
			else
				spr(2, ball.x, ball.y)
			end
		end
  }
end


function _init()
  init_ball()
end

-- ################################
-- ##   update
-- ################################
function _update60()
  if mode == "start" then
   update_start()
  elseif mode == "game" then
   update_game()
  elseif mode == "end" then
   update_end()
  end
end

function update_score_counter()
  if score_delay_counter>0 then
    score_delay_counter-=1
  else
    score_delay_counter=score_delay_counter_max
    if score_counter<score then score_counter+=1; sfx(3) end
  end
end

function update_start()
	if btn(5)then
    mode = "game"
    sfx(0)
  end
end

function update_game()
  pad:update()
  ball:update()
  court:update()
  update_score_counter()
end

function update_end()
	if btn(5) then
		mode="game"
		init_score()
		lives=3
	end
end

-- ################################
-- ##   draw
-- ################################
function _draw()

  if mode == 'start' then
    draw_start()
  elseif mode == 'game' then
    draw_game()
  elseif mode == 'end' then
    draw_end()
  end
end

function draw_start()
	cls()
	print ("___speedball````", 30, 10 )
  print ("press (x) to start", 30, 70)
end

function draw_game()
  cls()
  pad:draw()
  ball:draw()
  court:draw()
  draw_velocity()
  print("score:"..score_counter, 0,0, 7)
  for i = 1, lives do
  	spr(2, 85 + (10*i), 0)
	end
end

function draw_velocity()
  local v = ball:calculate_velocity()
  local x_offset=5
  local x_widht=5
  local y=127
  for i = 0,max_velocity,0.5 do
    -- local active_color = i<3 and 12 or i<4 and 8 or 10
    local color =  i<= v and velocity_color(i) or 5
    line(i*10+x_offset,y, i*10+(x_offset+x_widht),y ,color)
  end
end

function velocity_color(v)
  return v<3 and 12 or v<4 and 8 or 10
end

function draw_end()
	cls()
	print ("game over", 30,10)
	print ("your score: "..score, 30,30)
  print ("press (x) to play again",30,70)
end







-- globale functies
function overlap(e1, e2)
  return e1.x+e1.w >= e2.x and e1.x <= e2.x+e2.w and e1.y+e1.h >= e2.y and e1.y <= e2.y+e2.h
end

-- vergroot (negatief) of verklein (positief) de waarde van `val` met `amt` richting 0.
--  als het resultaat minder is dan `amt`vindt afronding naar 0 plaats
function reduce(val, amt)
  if val < -amt then
    return val + amt
  elseif val > amt then
    return val - amt
  else
    return 0
  end
end

-->8
--tabje twee
-->8
--tabje 3
__gfx__
000000000007777700fff00000fff00000fff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000007ddddd09999f0009999f0009999f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070007dddddd999999f0999999f0999999f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000075ddddd999999f0999999f0999999f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000006555554999999049999990444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000666660499990004444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000044400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
010d00001a0201d020260202d00032000320003200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002b3102d310313100000000000000000000000000000001100000000000000000000000000000000022000000000000000000000000000000000000000000000000000000000000000000000000000000
010d0000260201d0201a0202d00032000320003200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003e01000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
010d0000260201d0201a020100500e0500e0500e0500e050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
