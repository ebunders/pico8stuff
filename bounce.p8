pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

--ideen:
-- als de bal een object raakt licht die even op
-- aan het begin van het spel wordt de court als animatie getekent.
gravity=0.1

court = {
  {x1=3, y1=3, x2=3, y2=124},
  {x1= 124, y1=3, x2=124, y2=124},
  {x1=3, y1=3, x2=124, y2=3},
}

pad = {
  x=52,
  y=122,
  w=30,
  h=6,
  velocity=0,
  friction=0.6,
  acceleration=1,
  max_velocity=5
}

function init_ball()
  return {
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
    collide_court=function(self)
      if self.y<=3 then
        self.velocity_y= -self.velocity_y
        self.y=4
      end
      if self.x<=3 then
        self.velocity_x = -self.velocity_x
        self.x=4
      end
      if self.x>=(124-self.w) then
        self.velocity_x= -self.velocity_x
        self.x=123-self.w
      end
    end
  }
end

ball=init_ball()


function update_paddle()
  pad.velocity = reduce(pad.velocity, pad.friction)
	if btn(0) and pad.x > 3 then 	pad.velocity-=pad.acceleration end
	if btn(1) and pad.x < 127-(pad.w+3) then pad.velocity+=pad.acceleration end

  pad.x = mid(0, pad.x+pad.velocity, 127-pad.w)
end



function update_ball (args)
  ball.velocity_y = ball.velocity_y+gravity
  ball.y+=ball.velocity_y
  ball.x+=ball.velocity_x
  if ball.y > 127 then ball=init_ball() end
end

function _update60()
	update_paddle()
  update_ball()
  ball:collide_pad()
  ball:collide_court()
end


function _draw()
  cls()
  draw_lines(court,11)
  draw_paddle()
  draw_ball()
  print("velocity_y:"..ball.velocity_y, 3,3)
end

function draw_lines(lines, color)
  printh("test")
  for l in all(lines) do
    printh("line:")
    line(l.x1, l.y1, l.x2, l.y2, color)
  end
end

function draw_paddle()
  spr(1, pad.x, pad.y)
  spr(1, pad.x+(pad.w-8), pad.y, 1,1, true, false)
  if(pad.w > 16) then
    for l,c in pairs({[0]=7,[1]=13,[2]=13,[3]=13,[4]=5, [5]=6}) do
      printh(""..l)
      line(pad.x+8, pad.y+l, pad.x+(pad.w-8), pad.y+l, c)
    end
  end
end

function draw_ball()
  spr(2, ball.x, ball.y)
end

-- Globale functies
function overlap(e1, e2)
  return e1.x+e1.w >= e2.x and e1.x <= e2.x+e2.w and e1.y+e1.h >= e2.y and e1.y <= e2.y+e2.h
end

-- Vergroot (negatief) of verklein (positief) de waarde van `val` met `amt` richting 0.
--  Als het resultaat minder is dan `amt`vindt afronding naar 0 plaats
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
000500002103003000000000000000000000000000000000000001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00110000350102a0201f0301a04011050000000000000000000000000000000000001c00000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000
