

function createCoasterBody(x, y)

	body = love.physics.newBody( _world, x, y, "dynamic" )
	shape = love.physics.newRectangleShape(  0, 0, 16, 16, 0 )
	fixture = love.physics.newFixture(body, shape)
	
	obj = {}
	obj.Body = body
	obj.Shape = shape
	obj.Fixture = fixture
	obj.Type = "poly"
	return obj;
end

function createTestFloorBody()

	body = love.physics.newBody( _world, 0, WORLDHEIGHT-5, "static" )
	shape = love.physics.newRectangleShape(  0, 0, 400, 16, 0 )
	fixture = love.physics.newFixture(body, shape)
	
	obj = {}
	obj.Body = body
	obj.Shape = shape
	obj.Fixture = fixture
	obj.Type = "poly"

	return obj;

end

function drawObj( obj )

	if obj.Type == "poly" then
		love.graphics.line(obj.Body:getWorldPoints(obj.Shape:getPoints()))
	end

end
