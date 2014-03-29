WORLDHEIGHT = 640;
WORLDWIDTH = 960;

require "coasterLib"
require "background"

local afterGame = false;
local beforeGame = true;
function love.load()
	math.randomseed( os.time() )
	title = love.graphics.newImage('titlescreen.png')
	end_screen = love.graphics.newImage('Game_over.png')
	love.mouse.setVisible( true )

	song = love.audio.newSource('thesong.mp3')
	song:setLooping(true)
	song:setVolume(0.2)
	song:play()

	love.window.setMode( 960, 640, {})
	background.load()

end

function love.keypressed(key)
	if key == 'x' then
		coasterLib.startGame()
		love.mouse.setVisible( false )
		beforeGame = false
		afterGame = false
	elseif key == 'm' and afterGame == true then
		beforeGame = true
		afterGame = false
	end
end

function coasterLib.GameOver()
	afterGame = true;
	score = coasterLib.XScroll / 32
end

function love.update( dt )
   background.update(dt)
   if beforeGame or afterGame then return; end
   coasterLib.update( dt )

   _world:update( dt )
end


function love.draw() 
	background.draw()
	if afterGame then 
		displayEnd()
		return; 
	end
	if beforeGame then love.graphics.draw(title) return; end
	coasterLib.onDraw( _world )

end

function displayEnd()
	love.graphics.draw(end_screen)
		font = love.graphics.newFont(20)
		love.graphics.setFont(font)
		love.graphics.setColor(0,0,0)
 		love.graphics.printf('You went '..tostring(math.floor(score))..' meters!',
 			(WORLDWIDTH/2)-(font:getWidth('You went '..tostring(math.floor(score))..' meters!'))/2,
 			300,500,center)
 		love.graphics.setColor(255,255,255)
end
