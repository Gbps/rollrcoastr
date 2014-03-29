WORLDHEIGHT = 480;
WORLDWIDTH = 480;

require "coasterLib"


function love.load()

	love.physics.setMeter( 32 );
	_world = love.physics.newWorld(0, 9.81*32, true);

   coaster1Obj = createCoasterBody( 50, 50 ); -- Create coaster body
   floorObj = createTestFloorBody(); -- Create floor body ( bottom of the screen )

end

function love.update( dt )
   _world:update( dt );
end


function love.draw()

	-- Draw floor
	drawObj( coaster1Obj );

	-- Draw coaster
	drawObj( floorObj );

end
