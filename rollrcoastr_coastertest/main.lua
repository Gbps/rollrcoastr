WORLDHEIGHT = 640;
WORLDWIDTH = 960;

require "coasterLib"


function love.load()

	love.window.setMode( 960, 640, {});
	love.physics.setMeter( 32 );
	_world = love.physics.newWorld(0, 9.81*32, true);

	coaster1Obj = createCoaster( 5, 100, 100 ); -- Create coaster body
	floorObj = createTestFloorBody(); -- Create floor body ( bottom of the screen )

end

function love.update( dt )
   coasterLibUpdate( dt );

   _world:update( dt );
end


function love.draw()

	coasterLibDraw( _world );

end
