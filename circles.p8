pico-8 cartridge // http://www.pico-8.com
version 16
__lua__

local circles={}

function _init()
	add(circles, init_circle(40,40,10,0.2))
end

function _update()
	for c in all(circles)do
		c:update()
	end
end

function _draw()
	cls()
	for c in all(circles)do
		c:draw()
	end

end
-->8
-- objects

function init_circle(x,y,rad,spd)
	return {
		x=x,
		y=y,
		rad=rad,
		speed=spd,
		clr=13,
		r_rad=0,
		r_clr=6,
		rings={14,13,14,13,14},
		timer=0,
		
		draw=function(self)
			circfill(self.x, self.y, self.rad, self.clr)
			if self.timer==0 then
				for i=-2,2,1 do 
					local _rad = self.r_rad+i
					if _rad>0 and _rad<=self.rad then
						circ(self.x, self.y, _rad, self.rings[i+3])
					end
				end 
			end
		end,
		
		update=function(self)
			if self.timer>0 then
				self.timer-=1
			else
				self.r_rad+=self.speed
				if self.r_rad>self.rad then
					self.r_rad=0
					self.timer=5
				end
			end
		end
	}
end
