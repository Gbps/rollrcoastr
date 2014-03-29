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
		love.graphics.draw(end_screen)
 
		return; 
	end
	if beforeGame then love.graphics.draw(title) return; end
	coasterLib.onDraw( _world )

end
