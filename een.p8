pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- gloabal functions

--model
local score
local game_objects
local player

function _init()
  score=0
  game_objects={}
  player = create_player(64,14)

	for i = 1,3 do create_coin(30+15*i, 80) end

  for i=1,15 do create_block(8*i, 90) end
  create_block(50, 50)
  create_block(80, 70)
  create_block(20, 82)
end



-- game

function _update()
	for_all_objects(function(obj) obj:update() end)
end

function _draw()
	cls()
	print("score: "..abs(player.velocity_x), 0,0,7 )
	for_all_objects(function(o) o:draw() end)
end


function create_game_object(name,x,y,width,height,props)
	local obj={
		name=name,
		x=x,
		y=y,
		velocity_x=0,
		velocity_y=0,
		width =width,
		height = height,
		update=function(self)end,
		draw=function(self)end,
		
		check_for_hit=function(self, other)
			return overlap(self, other)
		end,

		check_for_collision=function(self, other)
			local x, y = self.x, self.y
      local top_hitbox= {x=x+3,       y=y,    width=2, height=4}
      local bottom_hitbox= {x=x+3,    y=y+4,  width=2, height=4}
      local left_hitbox= {x=x,        y=y+3,  width=4, height=2}
      local right_hitbox= {x=x+4,     y=y+3,  width=4, height=2}

      if overlap(other, bottom_hitbox)then
        return "down"
      elseif overlap(other, left_hitbox)then
        return "left"
      elseif overlap(other, right_hitbox)then
        return "right"
      elseif overlap(other, top_hitbox)then
        return "top"
      end
		end,

		handle_collision=function(self, block, collision_dir)
			if "down" == collision_dir then
	      self.y = block.y-self.height
	      self.velocity_y=min(0, self.velocity_y)
	    elseif "left" == collision_dir then
	      self.x = block.x + block.width
	      self.velocity_x=max(0, self.velocity_x)
	    elseif "right" == collision_dir then
	      self.x = block.x - self.width
	      self.velocity_x = min(0, self.velocity_x)
	    elseif "top" == collision_dir then
	      self.y = block.y + block.height
	      self.velocity_y = max(0, self.velocity)
      end
		end,

		draw_bounding_box=function(self, color)
			rect(self.x, self.y, self.x+self.width, self.y+self.height, color)
		end
	}

	for k,v in pairs(props)do obj[k]=v end
	add(game_objects, obj)
	return obj
end	

function create_coin(x,y)
	return  create_game_object("coin",x,y,6,6,{
		collected=false,

		draw=function(self)
	      if(not self.collected) then spr(7, self.x, self.y) end
	    end,

	  update=function(self)
	  	for_all_objects_of_type("block", 
	  		function(block)
	  			self:handle_collision(block, self:check_for_collision(block))
	  		end
	  	)
		end
	})
end

function create_block(x, y)
	return create_game_object("block",x,y,8,8,{
		draw=function(self)
	      spr(6, self.x, self.y)
	    end
  })
end

function create_player(x,y)
	return create_game_object("player",x,y,8,8,{
    speed=1,
    color=8,
    velocity_x=0,
    velocity_y=0,
    standing_on_block = false,
    is_facing_left=false,

    draw = function (self)
    	local sprite

    	if self.standing_on_block then
    		if abs(self.velocity_x) == 0 then
  				sprite = 8
  			else
  				sprite = 9
  			end
    	else
    		if self.velocity_y>0 then
    			sprite=11
    		else
    			sprite=12
    		end
    	end

      self:draw_bounding_box(7)
      spr(sprite, self.x, self.y,1,1, self.is_facing_left)
    end,

    update = function(self)
      -- apply friction
      self.velocity_x = mid(-3, self.velocity_x*0.2, 3)
      -- apply gravity
      self.velocity_y = mid(-3, self.velocity_y+0.1, 3)

      -- move the player with arrow keys
      if btn(1) then 
      	self.velocity_x = self.speed 
      	self.is_facing_left = false
      end
      if btn(0) then 
      	self.velocity_x = -self.speed 
      	self.is_facing_left = true
      end

      -- jump when z is pressed
      if btn(4) and self.standing_on_block then
        self.velocity_y = -3
      end

      -- apply velocity to speed
      self.x+= self.velocity_x
      self.y+= self.velocity_y

      --reset the jump switch
      self.standing_on_block = false
    
      --check for collisions with coins
      for_all_objects_of_type("coin", 
      	function(coin) 
      		if not coin.collected and self:check_for_hit(coin) then 
      			score+=1 
      			coin.collected = true	
      		end
      	end
    	)

      --check for collisions with blocks
			for_all_objects_of_type("block",
				function (block)
					local collision_dir = self:check_for_collision(block)
					self:handle_collision(block, collision_dir)
					if("down" == collision_dir) then self.standing_on_block = true end
				end
			)
    end,
  })
end

-- global functions
function for_all_objects(f) for o in all(game_objects) do f(o) end end
function for_all_objects_of_type(name, f)
	for_all_objects(function(obj) if obj.name==name then f(obj) end end)
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
000000000000000000000000000000000000b0000000b00077777777000000000030000000300000003000000030000000300000000000000000000000000000
000000000000000000000000000000000093b90000e3be007666666d0009aa000033330000333300003333000033330000333300000000000000000000000000
0070070000000000000000000000000099493494ee4ee4e47677776d009aaaa00099990000999900009999000094940000999900000000000000000000000000
0007700000000000000000000000000094999494e4eee4e476766d6d009aaaa00094940000949400009494000099990000999900000000000000000000000000
0007700000000000000000000000000094999499e4eee4ee76766d6d009aaaa00099990000999900009999000099994000949400000000000000000000000000
0070070000000000000000000000000094999499e4eee4ee76dddd6d009aaa700044444000444440004444400099990000999944000000000000000000000000
0000000000000000000000000000000099499499ee4ee4ee7666666d0009aa000044440000444400004444000444444004444440000000000000000000000000
00000000000000000000000000000000099449900ee44ee0dddddddd000000000040040004000440000440000000000000000000000000000000000000000000
