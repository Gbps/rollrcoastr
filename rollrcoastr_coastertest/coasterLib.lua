mouseLastX = -100;
mouseLastY = -100;
mousePressed = false;
mouseMaxX = 0;
XScroll = 0;
chainJoints = {}

function coasterLibUpdate( dt )
	local mouseX, mouseY = love.mouse.getPosition( )
	mouseX = mouseX + XScroll;

	if mouseLastX == -100 and mousePressed then
		mouseLastX = mouseX;
		mouseLastY = mouseY;
	end

	local absVal = math.abs( mouseLastX-mouseX ) + math.abs( mouseLastY-mouseY );

	if (mouseX > mouseLastX) and absVal > 10 and mousePressed and not (mouseLastX == mouseX and mouseLastY == mouseY) then
		createLineObj( mouseLastX, mouseLastY, mouseX, mouseY)
		mouseLastX = mouseX;
		mouseLastY = mouseY;
	end
	
	XScroll = XScroll + dt*120;
end

function love.mousepressed(x, y, button)
   mousePressed = true;
end

function love.mousereleased(x, y, button)
	mousePressed = false;
end

function createLineObj( x1, y1, x2, y2)
	local body = love.physics.newBody( _world, 0, 0, "static" )
	local shape = love.physics.newEdgeShape( x1, y1, x2, y2 )
	local fixture = love.physics.newFixture(body, shape)
	fixture:setFriction(1)
	return obj;
end

function createCoasterBody(x, y, n, first)

	local body = love.physics.newBody( _world, x, y, "dynamic" )
	local shape = love.physics.newRectangleShape(  0, 0, 80, 40, 0 )
	local fixture = love.physics.newFixture(body, shape)
	fixture:setGroupIndex( -1 - n );
	fixture:setDensity( 30 );
	fixture:setFriction( 0 );
	fixture:setRestitution( 0.3 );
	if first == true then
		fixture:setUserData( "coasterCarFirst" )
	else
		fixture:setUserData( "coasterCar" )
	end

	local axel_shape1 = love.physics.newRectangleShape(  0, 0, 8, 8, 0 )
	local axel_shape2 = love.physics.newRectangleShape(  0, 0, 8, 8, 0 )
	

	local axel1_b = love.physics.newBody( _world, x-(32/2)-5, y+22, "dynamic")
	local axel1_f = love.physics.newFixture( axel1_b, axel_shape2 )
	axel1_f:setGroupIndex( -1 - n );

	axel1_f:setDensity( 0.5 );
	axel1_f:setFriction( 3 );	
	axel1_f:setRestitution( 0.3 );

	local axel2_b = love.physics.newBody( _world, x+7+(32/2), y+22, "dynamic")
	local axel2_f = love.physics.newFixture( axel2_b, axel_shape1 )
	axel2_f:setGroupIndex( -1 - n );
	axel2_f:setDensity( 0.5 );
	axel2_f:setFriction( 3 );
	axel2_f:setRestitution( 0.3 );
	

	local wheel1_s = love.physics.newCircleShape( 0, 0, 10 )
	local wheel1_b = love.physics.newBody( _world, x-(32/2)-5, y+22, "dynamic")
	local wheel1_f = love.physics.newFixture( wheel1_b, wheel1_s )
	wheel1_f:setGroupIndex( -1 - n);

	wheel1_f:setGroupIndex( -1 - n );
	wheel1_f:setDensity( 1 );
	wheel1_f:setFriction( 10 );
	wheel1_f:setRestitution( 0.1 );
	wheel1_f:setUserData( "wheel");

	local wheel2_s = love.physics.newCircleShape( 0, 0, 10 )
	local wheel2_b = love.physics.newBody( _world, x+7+(32/2), y+22, "dynamic")
	local wheel2_f = love.physics.newFixture( wheel2_b, wheel2_s )
	wheel2_f:setGroupIndex( -1 - n);

	wheel2_f:setGroupIndex( -1 - n );
	wheel2_f:setDensity( 1 );
	wheel2_f:setFriction( 5 );
	wheel2_f:setRestitution( 0.1 );
	wheel2_f:setUserData( "wheel");
	
	
	local x1, y1 = wheel1_b:getWorldCenter()
	local wheel1_j = love.physics.newRevoluteJoint( wheel1_b, axel1_b, x1, y1, false )
	wheel1_j:setMotorEnabled( true );
	wheel1_j:setMotorSpeed( -20 );
	wheel1_j:setMaxMotorTorque( 50000 );

	local x1, y1 = wheel2_b:getWorldCenter()
	local wheel2_j = love.physics.newRevoluteJoint( wheel2_b, axel2_b, x1, y1, false )

	wheel2_j:setMotorEnabled( true );
	wheel2_j:setMotorSpeed( -20 );
	wheel2_j:setMaxMotorTorque( 50000 );
	local x1, y1 = axel1_b:getWorldCenter()
	local w1_prisjoint = love.physics.newPrismaticJoint( body, axel1_b, x1, y1, 0, 1, false )

	w1_prisjoint:setLimitsEnabled(true);
	w1_prisjoint:setLowerLimit(0);
	w1_prisjoint:setUpperLimit(5);
	
	local x1, y1 = axel2_b:getWorldCenter()
	local w2_prisjoint = love.physics.newPrismaticJoint( body, axel2_b, x1, y1, 0, 1, false )

	w2_prisjoint:setLimitsEnabled(true);
	w2_prisjoint:setLowerLimit(0);
	w2_prisjoint:setUpperLimit(5);

	local obj = {}
	obj.Body = body
	obj.Shape = shape
	obj.Fixture = fixture
	obj.Type = "poly" -- How it should be drawn


	return obj;
end

function createCoaster( numParts, x, y)

	local bodies = {}
	local lastBody;
	local lastX;
	local n = 0;
	for i=1, numParts do
		local body = createCoasterBody( x+(i*90), y, n, (numParts == i))
		n = n + 1;
		if lastBody ~= nil then
			local bodyCoordsX, bodyCoordsY  = body.Body:getWorldCenter();
			local lastBodyCoordsX, lastBodyCoordsY = lastBody.Body:getWorldCenter()
			local attchJoint = love.physics.newRopeJoint( body.Body, lastBody.Body, bodyCoordsX-40, bodyCoordsY, lastBodyCoordsX+40, lastBodyCoordsY, 20, true )
			table.insert(chainJoints, attchJoint);
		end
		lastX = x+(i*90);
		lastBody = body;
	end
end

function createTestFloorBody()

	local body = love.physics.newBody( _world, 0, 0, "static" )
	local shape = love.physics.newEdgeShape( 0, WORLDHEIGHT/2, WORLDWIDTH, WORLDHEIGHT/2 )
	local fixture = love.physics.newFixture(body, shape)
	
	local obj = {}
	obj.Body = body
	obj.Shape = shape
	obj.Fixture = fixture
	obj.Type = "edge"

	return obj;

end

function coasterLibDraw( world )
	if (worldSprites == nil ) then loadWorldSprites(); end
	love.graphics.translate( -XScroll, 0);
	spriteWorldDraw( world )
end

function loadWorldSprites( )
	worldSprites = {}
	worldSprites["coasterCarFirst"] = love.graphics.newImage("car_h.png");
	worldSprites["coasterCar"] = love.graphics.newImage("car_b_1.png");
	worldSprites["wheel"] = love.graphics.newImage("wheel.png");
	worldSprites["chain"] = love.graphics.newImage("chain.png");
end

function angleBetween( x1, y1, x2, y2)
	return math.atan2((y2 - y1), (x2 - x1))
end

function distanceBetween ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

function spriteWorldDraw(world)
	local bodies = world:getBodyList()
   
   for b=#bodies,1,-1 do
      local body = bodies[b]
      local bx,by = body:getPosition()
      local bodyAngle = body:getAngle()
      love.graphics.push()
      love.graphics.translate(bx,by)
      love.graphics.rotate(bodyAngle)
      
      local fixtures = body:getFixtureList()
      for i=1,#fixtures do
      	local fixture = fixtures[i];
      	local data = fixture:getUserData();
      	local sprite = worldSprites[data];
      	local shape = fixture:getShape()
        local shapeType = shape:getType()
        if (shapeType == "edge") then
            love.graphics.setColor(255,255,255,255)
            love.graphics.line(shape:getPoints())
      	elseif (sprite ~= nil) then
      		local centerX, centerY = fixture:getMassData()
      		local width = sprite:getWidth()
  			local height = sprite:getHeight()
      		love.graphics.draw(sprite, centerX, centerY, 0, 1, 1, width / 2, height / 2)
      	end

      end

      love.graphics.pop()
   end

   local joints = world:getJointList()
   for index,joint in pairs(chainJoints) do
      local x1,y1,x2,y2 = joint:getAnchors()
      if (x1 and x2) then
      	 local angle = angleBetween( x1, y1, x2, y2);
      	 local length = distanceBetween( x1, y1, x2, y2);
      	 local quad = love.graphics.newQuad( 0, 0, length, 6, 20, 6 )
      	 love.graphics.draw(worldSprites["chain"], quad, x1, y1, angle, 1, 1)
      end
   end

end
function debugWorldDraw(world)
   local bodies = world:getBodyList()
   
   for b=#bodies,1,-1 do
      local body = bodies[b]
      local bx,by = body:getPosition()
      local bodyAngle = body:getAngle()
      love.graphics.push()
      love.graphics.translate(bx,by)
      love.graphics.rotate(bodyAngle)
      
      math.randomseed(1) --for color generation
      
      local fixtures = body:getFixtureList()
      for i=1,#fixtures do
         local fixture = fixtures[i]
         local shape = fixture:getShape()
         local shapeType = shape:getType()
         local isSensor = fixture:isSensor()
         
         if (isSensor) then
            love.graphics.setColor(0,0,255,96)
         else
            love.graphics.setColor(math.random(32,200),math.random(32,200),math.random(32,200),96)
         end
         
         love.graphics.setLineWidth(1)
         if (shapeType == "circle") then
            local x,y = fixture:getMassData() --0.9.0 missing circleshape:getPoint()
            --local x,y = shape:getPoint() --0.9.1
            local radius = shape:getRadius()
            love.graphics.circle("fill",x,y,radius,15)
            love.graphics.setColor(255,255,255,255)
            love.graphics.circle("line",x,y,radius,15)
            local eyeRadius = radius/4
            love.graphics.setColor(0,0,0,255)
            love.graphics.circle("fill",x+radius-eyeRadius,y,eyeRadius,10)
         elseif (shapeType == "polygon") then
            local points = {shape:getPoints()}
            love.graphics.polygon("fill",points)
            love.graphics.setColor(255,255,255,255)
            love.graphics.polygon("line",points)
         elseif (shapeType == "edge") then
            love.graphics.setColor(255,255,255,255)
            love.graphics.line(shape:getPoints())
         elseif (shapeType == "chain") then
            love.graphics.setColor(0,0,0,255)
            love.graphics.line(shape:getPoints())
         end
      end
      love.graphics.pop()
   end
   
   local joints = world:getJointList()
   for index,joint in pairs(joints) do
      love.graphics.setColor(0,255,0,255)
      local x1,y1,x2,y2 = joint:getAnchors()
      if (x1 and x2) then
         love.graphics.setLineWidth(3)
         love.graphics.line(x1,y1,x2,y2)
      else
         love.graphics.setPointSize(3)
         if (x1) then
            love.graphics.point(x1,y1)
         end
         if (x2) then
            love.graphics.point(x2,y2)
         end
      end
   end
   
   local contacts = world:getContactList()
   for i=1,#contacts do
      love.graphics.setColor(255,0,0,255)
      love.graphics.setPointSize(3)
      local x1,y1,x2,y2 = contacts[i]:getPositions()
      if (x1) then
         love.graphics.point(x1,y1)
      end
      if (x2) then
         love.graphics.point(x2,y2)
      end
   end
end