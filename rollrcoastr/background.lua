background = {}

hillpos = 0
HILLWIDTH = 1920
HILLRATE = -6
hillnum = 0

hill2pos = -800
HILL2RATE = -4
hill2num = 0

skypos = 0
SKYWIDTH = 3680
SKYRATE = -3
skynum = 0

parkpos = 0
PARKWIDTH = 5110
PARKRATE = -5
parknum = 0

SCREENWIDTH = 960
SCREENHEIGHT = 640

VERTCONST = 50

function background.load()
	hills = love.graphics.newImage('hills.png')
	hills2 = love.graphics.newImage('hills2.png')
	sky = love.graphics.newImage('sky.png')
	park = love.graphics.newImage('park.png')
end

function background.draw()
	love.graphics.draw(sky, skypos, vertpar * SKYRATE - VERTCONST - 100)
	if SKYWIDTH * skynum - skypos < SCREENWIDTH then
		love.graphics.draw(sky, SKYWIDTH + skypos, vertpar * SKYRATE - VERTCONST - 100)
	end

	love.graphics.draw(hills2, hill2pos, vertpar * HILL2RATE - VERTCONST)
	if HILLWIDTH * hill2num - hill2pos < SCREENWIDTH then
		love.graphics.draw(hills2, HILLWIDTH + hill2pos, vertpar * HILL2RATE - VERTCONST)
	end

	love.graphics.draw(park, parkpos, vertpar * PARKRATE - VERTCONST)
	if PARKWIDTH * parknum - parkpos < SCREENWIDTH then
		love.graphics.draw(park, PARKWIDTH + parkpos, vertpar * PARKRATE - VERTCONST)
	end

	love.graphics.draw(hills, hillpos, vertpar * HILLRATE -VERTCONST)
	if HILLWIDTH * hillnum - hillpos < SCREENWIDTH then
		love.graphics.draw(hills, HILLWIDTH + hillpos, vertpar * HILLRATE - VERTCONST)
	end
end

function background.getVerticalConstant()
	x,y = love.mouse.getPosition()
	return (y - (SCREENHEIGHT/2))/20;
end

function background.update(dt)
	--vertical parallaxing
	x,y = love.mouse.getPosition()
	vertpar = background.getVerticalConstant();

	--horizontal parallaxing
	hillpos = hillpos + HILLRATE
	skypos = skypos + SKYRATE
	hill2pos = hill2pos + HILL2RATE
	parkpos = parkpos + PARKRATE

	hillnum = math.floor(hillpos / HILLWIDTH)
	if hillnum ~= prevhillnum then
		hillpos = 0
		prevhillnum = hillnum
	end

	hill2num = math.floor(hill2pos / HILLWIDTH)
	if hill2num ~= prevhill2num then
		hill2pos = 0
		prevhill2num = hill2num
	end

	skynum = math.floor(skypos / SKYWIDTH)
	if skynum ~= prevskynum then
		skypos = 0
		prevskynum = skynum
	end

	parknum = math.floor(parkpos / PARKWIDTH)
	if parknum ~= prevparknum then
		parkpos = 0
		prevparknum = parknum
	end
end

