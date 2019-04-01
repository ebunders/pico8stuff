pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--ideen:
-- als de bal een object raakt licht die even op
-- aan het begin van het spel wordt de court als animatie getekent.
local gravity=0.1
local score=0
local mode='START'
local play_mode = ''
local lives=3

local court = {
  is_colliding=false,
  collision_counter=0,
  color=11,
  colliding_color=8,
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
    local color = ((self.collision_counter>0) and self.colliding_color or self.color)
    for l in all(self.lines) do
      line(l.x1, l.y1, l.x2, l.y2, color)
    end
  end
}

local pad = {
  x=52,
  y=122,
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
        printh(""..l)
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

    collide_pad = function(self)
      if overlap(self,pad) then
        if not self.colliding then sfx(1) end
        self.colliding = true
        self.y=pad.y-self.h
        self.velocity_y= -mid(0, self.velocity_y - pad.friction + abs(pad.velocity), 5)
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
        self.handle_collision()
      end
      if self.x<=3 then
        self.velocity_x = -self.velocity_x
        self.x=4
        self.handle_collision()
      end
      if self.x>=(124-self.w) then
        self.velocity_x= -self.velocity_x
        self.x=123-self.w
        self.handle_collision()
      end
    end,

    handle_collision= function(self)
      court.is_colliding=true
      score+=1
    end,

    update = function (self)
    	if play_mode == 'NEW_BALL' then
    		-- start new ball
    		if btn(5) then play_mode='' end
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
		       	play_mode="NEW_BALL"
		      else
		       	mode="END"
					end
	    	end
    	end
	  end,

	  draw= function(self)
	  	if play_mode == "NEW_BALL" then
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
-- ##   UPDATE 
-- ################################
function _update60()
	 if mode == "START" then
     update_start()
   elseif mode == "GAME" then
     update_game()
   elseif mode == "END" then
     update_end()
   end

end

function update_start()
	if btn(5)then mode = "GAME" end
end

function update_end()
	if btn(5) then 
		mode="GAME"
		score=0
		lives=3 
	end
end

function update_game()
  pad:update()
  ball:update()
  court:update()
end



-- ################################
-- ##   DRAW
-- ################################
function _draw()

  if mode == 'START' then
    draw_start()
  elseif mode == 'GAME' then
    draw_game()
  elseif mode == 'END' then
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
  print("score:"..score, 0,0, 7)
  for i = 1, lives do
  	spr(2, 50 + (12*i), 0)
	end	

end

function draw_end()
	cls()
	print ("GAME OVER", 30,10)
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
000d00001a0201d020210202d02032020320203200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200002b3102d310313100000000000000000000000000000001100000000000000000000000000000000022000000000000000000000000000000000000000000000000000000000000000000000000000000
00110000350102a0201f0301a04011050000000000000000000000000000000000001c00000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000
