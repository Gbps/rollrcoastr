WORLDHEIGHT = 640;
WORLDWIDTH = 960;

require "coasterLib"
require "background"

function love.load()
	math.randomseed( os.time() )
	coasterLib.startGame()
	love.mouse.setVisible( false );

end

function coasterLib.GameOver()

end

function love.update( dt )
   background.update(dt)
   coasterLib.update( dt );

   _world:update( dt );
end


function love.draw() 
	background.draw()
	coasterLib.onDraw( _world );

end
