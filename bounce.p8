pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
padx=52
pady=122
padw=24
padh=4
ballx=64
bally=64
ballsize=3
ballxdir=4
ballydir=2

function movepaddle()
	if btn(0) and padx > 3 then 	padx -=3 end
	if btn(1) and padx < 127-(padw+3) then padx +=3 end
end

function moveball()
	ballx+=ballxdir
	bally+=ballydir
end

function bounceball()
	if ballx < 0 or ballx > 128-ballsize then
		ballxdir = -ballxdir
		sfx(0)
	end
	if bally<0 then
		ballydir = -ballydir
		sfx(0)
	end
end

function bouncepaddle()
	if bally+ballsize >= pady and padx<ballx and padx+padw>ballx+ballsize then
		ballydir= -ballydir
    	sfx(1)
	end
end

function loseball()
	if bally>128 then 
		bally = 24 
		sfx(2)
	end
end

function _update()
	movepaddle()
	bounceball()
	bouncepaddle()
	loseball()
	moveball()
end


function _draw()
	rectfill(0,0,128,128,3)
	rectfill(padx, pady, padx+padw, pady+padh, 12)
	circfill(ballx, bally, ballsize, 12)
end
__sfx__
000100003303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00050000193300b220003000030000300003000030000300003001120000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300003000030000300
00110000350102a0201f0301a04011050000000000000000000000000000000000001c00000000000000800000000000000000000000000000000000000000000000000000000000000000000000000000000000
