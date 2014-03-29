coasterLib = {}
local cl = coasterLib;

cl.mouseLastX = -100;
cl.mouseLastY = -100;
cl.mouseMaxX = 0;
cl.XScroll = 0;
cl.chainJoints = {}
cl.coasterBodies = {1,2,3,4,5,6}
cl.wheelFixtures = {}
cl.FastSpeed = false;
cl.FirstCar = nil;
cl.EnemyList = {}
cl.RandomProductionSpeed = false;
cl.ProductionSpeed = 240;
cl.reversedControls = false;
cl.reversedMouse = false;
function cl.startGame()
	if _world ~= nil then
		cl.mouseLastX = -100;
		cl.mouseLastY = -100;
		cl.mouseMaxX = 0;
		cl.XScroll = 0;
		cl.chainJoints = {}
		cl.coasterBodies = {1,2,3,4,5,6}
		cl.wheelFixtures = {}
		cl.FastSpeed = false;
		cl.FirstCar = nil;
		cl.SaveCoordY = nil;
		cl.SaveCoordX = nil;
		cl.SmoothMouseY = nil;
		cl.enemySpawn = true;
		cl.enemies = {}
		cl.enemyTimer = 0;
		cl.enemyDelay = 200;
		cl.RandomProductionSpeed = false;
		cl.ProductionSpeed = 240;
		cl.reversedControls = false;
		cl.reversedMouse = false;
		for i,k in pairs(cl.enemies) do
			k:Destroy();
		end
	end
	love.window.setMode( 960, 640, {});
	love.physics.setMeter( 32 );
	_world = love.physics.newWorld(0, 9.81*32, true);


	coaster1Obj = cl.createCoaster( 5, -50, 100 ); -- Create coaster body
	floorObj = cl.createStartingFloorBody(); -- Create floor body ( bottom of the screen )

	background.load()
	slowCon = love.audio.newSource('slowConstruction.wav')
	slowCon:setVolume(0.2)
	fallingObject = love.audio.newSource('fallingObject.wav')
	fallingObject:setVolume(0.2)
	gameOver = love.audio.newSource('gameOver.wav')
	fallingObject:setVolume(0.2)

end

function math.Clamp(val, lower, upper)
    if lower > upper then lower, upper = upper, lower end -- swap if boundaries supplied the wrong way
    return math.max(lower, math.min(upper, val))
end

function cl.update( dt )
	
	cl.checkLostGame();

	local mouseX, mouseY = love.mouse.getPosition( )

	if( cl.SaveCoordY == nil ) then cl.SaveCoordY = 600; end
	if( cl.SaveCoordX == nil ) then cl.SaveCoordX = 500; end
	if( cl.SmoothMouseY == nil) then cl.SmoothMouseY = 600; end
	if cl.constructionEmitter == nil then cl.createParticleEmitter() end

	cl.XScroll = cl.XScroll + dt*cl.ProductionSpeed;

	if( love.keyboard.isDown("q")) then
		if cl.FastSpeed then
		  	cl.ProductionSpeed = 450;
		else
			cl.ProductionSpeed = 320;
		end
	elseif( love.keyboard.isDown("w")) then
	  	if cl.FastSpeed then
		  	cl.ProductionSpeed = 50;
		else
			cl.ProductionSpeed = 180;
		end
	else
		cl.ProductionSpeed = 240;
	end
	
	if cl.reversedControls then

		if cl.ProductionSpeed > 240 then
			cl.ProductionSpeed = cl.ProductionSpeed-240;
		elseif cl.ProductionSpeed < 240 then
			cl.ProductionSpeed = 240+cl.ProductionSpeed;
		end
	end

	if (not cl.reversedMouse) then
		cl.SmoothMouseY = math.Clamp( cl.SmoothMouseY - ( ( cl.SmoothMouseY - mouseY) * .02 ), 0, SCREENHEIGHT);
	else
		cl.SmoothMouseY = math.Clamp( cl.SmoothMouseY + ( ( cl.SmoothMouseY - mouseY) * .02 ), 0, SCREENHEIGHT);
	end
	if math.abs(cl.SaveCoordX - (500+cl.XScroll) ) > 35 then
		
		local randomY = 0;
		if cl.RandomProductionSpeed then
			randomY = math.random(0,24) - math.random(0,24);
		end
		cl.createLineObj( cl.SaveCoordX, cl.SaveCoordY, 500+cl.XScroll, cl.SmoothMouseY+randomY);
		cl.SaveCoordX = 500+cl.XScroll;
		cl.SaveCoordY = cl.SmoothMouseY+randomY;
	end

	cl.constructionEmitter:start( )
	cl.constructionEmitter:update( dt )

	cl.EnemyThink()
end

function cl.checkLostGame()

	if cl.FirstCar == nil then return; end

	local x, y = cl.FirstCar:getWorldCenter()
	if x+40 >= 550+cl.XScroll then
		coasterLib.GameOver();
		gameOver:play()
		cl.startGame();
	elseif x+40 <= cl.XScroll then
		coasterLib.GameOver();
		gameOver:play()
		cl.startGame()
    elseif y >= WORLDHEIGHT then
    	coasterLib.GameOver();
    	gameOver:play()
    	cl.startGame()
    end


end

function cl.createParticleEmitter()
	 if (cl.worldSprites == nil ) then cl.loadWorldSprites(); end
	 cl.constructionEmitter = love.graphics.newParticleSystem(cl.worldSprites["dust"], 400)
	  --3b. set various elements of that particle system, please refer the wiki for complete listing
	  cl.constructionEmitter:setEmissionRate          (50  )
	  cl.constructionEmitter:setEmitterLifetime              (1)
	  cl.constructionEmitter:setParticleLifetime          (1)
	  cl.constructionEmitter:setPosition              (0, 0)
	  cl.constructionEmitter:setDirection             (0)
	  cl.constructionEmitter:setSpread                (360)
	  cl.constructionEmitter:setSpeed                 (10, 30)
	  cl.constructionEmitter:setLinearAcceleration    (0, 0)
	  cl.constructionEmitter:setRadialAcceleration    (10)
	  cl.constructionEmitter:setTangentialAcceleration(0)
	  cl.constructionEmitter:setSizes                 (2)
	  cl.constructionEmitter:setSizeVariation         (0.5)
	  cl.constructionEmitter:setRotation              (0)
	  cl.constructionEmitter:setSpin                  (0)
	  cl.constructionEmitter:setSpinVariation         (0)
	  cl.constructionEmitter:setColors                (200, 200, 255, 240, 255, 255, 255, 10)
	  cl.constructionEmitter:stop()
end

local supportCount = 0;

function cl.createLineObj( x1, y1, x2, y2)
	slowCon:play()

	local body = love.physics.newBody( _world, 0, 0, "static" )
	local shape = love.physics.newEdgeShape( x1, y1, x2, y2 )
	local fixture = love.physics.newFixture(body, shape)
	supportCount = supportCount + 1;
	fixture:setUserData("track");
	if supportCount >= 5 then
		supportCount = 0;
		fixture:setUserData("track_support");
	end
	fixture:setFriction(1)
	return obj;
end


table.indexOf = function( t, object )
	local result
 
	if "table" == type( t ) then
		for i=1,#t do
			if object == t[i] then
				result = i
				break
			end
		end
	end
 
	return result
end

function cl.createCoasterBody(x, y, n, first)

	local body = love.physics.newBody( _world, x, y, "dynamic" )
	local shape = love.physics.newRectangleShape(  0, 0, 80, 40, 0 )
	local fixture = love.physics.newFixture(body, shape)
	fixture:setGroupIndex( -1 - n );
	fixture:setDensity( 30 );
	fixture:setFriction( 0 );
	fixture:setRestitution( 0.3 );
	if first == true then
		fixture:setUserData( "coasterCarFirst" )
		cl.FirstCar = body;
	else
		local numSelected = cl.coasterBodies[ math.random( #cl.coasterBodies ) ];
		fixture:setUserData( "coasterCar" .. numSelected )
		table.remove( cl.coasterBodies, table.indexOf(cl.coasterBodies, numSelected));
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

	table.insert( cl.wheelFixtures, wheel1_f);

	local wheel2_s = love.physics.newCircleShape( 0, 0, 10 )
	local wheel2_b = love.physics.newBody( _world, x+7+(32/2), y+22, "dynamic")
	local wheel2_f = love.physics.newFixture( wheel2_b, wheel2_s )
	wheel2_f:setGroupIndex( -1 - n);

	wheel2_f:setGroupIndex( -1 - n );
	wheel2_f:setDensity( 1 );
	wheel2_f:setFriction( 5 );
	wheel2_f:setRestitution( 0.1 );
	wheel2_f:setUserData( "wheel");
	
	table.insert( cl.wheelFixtures, wheel2_f);
	
	local x1, y1 = wheel1_b:getWorldCenter()
	local wheel1_j = love.physics.newRevoluteJoint( wheel1_b, axel1_b, x1, y1, false )
	wheel1_j:setMotorEnabled( true );
	wheel1_j:setMotorSpeed( -31 );
	wheel1_j:setMaxMotorTorque( 100000 );

	local x1, y1 = wheel2_b:getWorldCenter()
	local wheel2_j = love.physics.newRevoluteJoint( wheel2_b, axel2_b, x1, y1, false )

	wheel2_j:setMotorEnabled( true );
	wheel2_j:setMotorSpeed( -31 );
	wheel2_j:setMaxMotorTorque( 100000 );
	
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

cl.enemySpawn = false;
cl.enemies = {}
cl.enemyTimer = 0;
cl.enemyDelay = 200;
function cl.EnemyThink()
	
	cl.enemyTimer = cl.enemyTimer + 1;
	if cl.enemyTimer == cl.enemyDelay then
		cl.enemySpawn = true;
		cl.enemyTimer = 0;
	end

	if cl.enemySpawn == true then
		local newEnemy = cl.EnemyList[ math.random( #cl.EnemyList ) ] ;
		if( newEnemy:IsHard() ) then
			newEnemy = cl.EnemyList[ math.random( #cl.EnemyList ) ]; -- This one is difficult
		end

		local enemy = newEnemy:New();
		cl.enemySpawn = false;
		cl.enemyDelay = cl.enemyDelay - math.random(2,5)
		enemy:Spawn( cl.XScroll+SCREENWIDTH+500, 0);


		table.insert(cl.enemies, enemy)
	end

	for i,k in pairs(cl.enemies) do

		if (k.XOffset+100 < cl.XScroll) then
			k:Destroy();
		end
	end

end

function cl.EnemyDraw()

	for i,k in pairs(cl.enemies) do
		k:Draw();
	end
end



function cl.createCoaster( numParts, x, y)

	local bodies = {}
	local lastBody;
	local lastX;
	local n = 0;
	for i=1, numParts do
		local body = cl.createCoasterBody( x+(i*90), y, n, (numParts == i))
		n = n + 1;
		if lastBody ~= nil then
			local bodyCoordsX, bodyCoordsY  = body.Body:getWorldCenter();
			local lastBodyCoordsX, lastBodyCoordsY = lastBody.Body:getWorldCenter()
			local attchJoint = love.physics.newRopeJoint( body.Body, lastBody.Body, bodyCoordsX-40, bodyCoordsY, lastBodyCoordsX+40, lastBodyCoordsY, 20, true )
			table.insert(cl.chainJoints, attchJoint);
		end
		lastX = x+(i*90);
		lastBody = body;
	end
end

function cl.createStartingFloorBody()

	local body = love.physics.newBody( _world, 0, 0, "static" )
	local shape = love.physics.newEdgeShape( 0, WORLDHEIGHT/2, WORLDWIDTH, WORLDHEIGHT/2 )
	local fixture = love.physics.newFixture(body, shape)
	fixture:setUserData("init_floor");

	local obj = {}
	obj.Body = body
	obj.Shape = shape
	obj.Fixture = fixture
	obj.Type = "edge"

	return obj;

end

function cl.onDraw( world )
	if (cl.worldSprites == nil ) then cl.loadWorldSprites(); end

	love.graphics.translate( -cl.XScroll, 0);
	cl.spriteWorldDraw( world )
	cl.EnemyDraw()
	love.graphics.draw(cl.worldSprites["cursor"], love.mouse.getX()+cl.XScroll, love.mouse.getY())

	love.graphics.draw(cl.constructionEmitter, 500+cl.XScroll, cl.SmoothMouseY)
end

function cl.loadWorldSprites( )
	--love.graphics.setDefaultFilter("nearest", "nearest")
	cl.worldSprites = {}
	cl.worldSprites["coasterCarFirst"] = love.graphics.newImage("car_h.png");
	cl.worldSprites["coasterCar1"] = love.graphics.newImage("car_b_1.png");
	cl.worldSprites["coasterCar2"] = love.graphics.newImage("car_b_2.png");
	cl.worldSprites["coasterCar3"] = love.graphics.newImage("car_b_3.png");
	cl.worldSprites["coasterCar4"] = love.graphics.newImage("car_b_4.png");
	cl.worldSprites["coasterCar5"] = love.graphics.newImage("car_b_5.png");
	cl.worldSprites["coasterCar6"] = love.graphics.newImage("car_b_6.png");
	cl.worldSprites["wheel"] = love.graphics.newImage("wheel.png");
	cl.worldSprites["chain"] = love.graphics.newImage("chain.png");
	cl.worldSprites["rail"] = love.graphics.newImage("rail.png");
	cl.worldSprites["cursor"] = love.graphics.newImage("cur_t.png");
	cl.worldSprites["track"] = love.graphics.newImage("track.png");
	cl.worldSprites["dust"] = love.graphics.newImage("dust.png");
	cl.worldSprites["beachball"] = love.graphics.newImage("bball.png");
	cl.worldSprites["wheel32"] = love.graphics.newImage("wheel32.png");
	cl.worldSprites["crate"] = love.graphics.newImage("crate.png");
	cl.worldSprites["support"] = love.graphics.newImage("support.png");
	cl.worldSprites["track_init"] = love.graphics.newImage("track_init.png");
end

function angleBetween( x1, y1, x2, y2)
	return math.atan2((y2 - y1), (x2 - x1))
end

function distanceBetween ( x1, y1, x2, y2 )
  local dx = x1 - x2
  local dy = y1 - y2
  return math.sqrt ( dx * dx + dy * dy )
end

function angleVector( angle )
	return math.cos(angle), math.sin(angle);
end

function cl.spriteWorldDraw(world)
	local bodies = world:getBodyList()
   	local verticalOffset = background.getVerticalConstant()*2;
   for b=#bodies,1,-1 do
      local body = bodies[b]
      local bx,by = body:getPosition()
      local bodyAngle = body:getAngle()
     
      love.graphics.push()
      love.graphics.translate(bx,by-verticalOffset)
      love.graphics.rotate(bodyAngle)
      	
      local fixtures = body:getFixtureList()
      for i=1,#fixtures do
      	local fixture = fixtures[i];
      	local data = fixture:getUserData();
      	local sprite = cl.worldSprites[data];
      	local shape = fixture:getShape()
        local shapeType = shape:getType()
        local supportCount = 0;
        if (shapeType == "edge") then
        	x1, y1, x2, y2 = shape:getPoints()
        	if( x2 < cl.XScroll-300 ) then
        		body:destroy();
        	elseif data == "init_floor" then
        		local trackSprite = cl.worldSprites["track_init"];
        		love.graphics.draw(trackSprite, x1, y1, 0, 1, 1, 0, 0);
        		love.graphics.draw(trackSprite, x1+190, y1, 0, 1, 1, 0, 0);
        		love.graphics.draw(trackSprite, x1+380, y1, 0, 1, 1, 0, 0);
        		love.graphics.draw(trackSprite, x1+570, y1, 0, 1, 1, 0, 0);
        		love.graphics.draw(trackSprite, x1+760, y1, 0, 1, 1, 0, 0);
        		
        	elseif data == "track" or data == "track_support" then
	            local x1, y1, x2, y2 = shape:getPoints()

        		if LastCoordX == nil then
        			LastCoordX = x1;
        			LastCoordY = y1;
        		end
	            local trackSprite = cl.worldSprites["track"];
		        local angle = angleBetween( x1, y1, x2, y2)
		        love.graphics.draw(trackSprite, LastCoordX, LastCoordY, angle, 1, 1, trackSprite:getWidth()/2, trackSprite:getHeight()/2);
		        LastCoordX = x1 + 35 * math.cos( angle );
				LastCoordY = y1 + 35 * math.sin( angle );
				supportCount = supportCount + 1;
				if (data == "track_support") then
					local supportSprite = cl.worldSprites["support"];
					love.graphics.draw( supportSprite, x2, y2, 0, 1, 1, supportSprite:getWidth(), 0)
					supportCount = 0;
				end
	        end
      	elseif (sprite ~= nil) then
      		local centerX, centerY = fixture:getMassData()
      		local width = sprite:getWidth()
  			local height = sprite:getHeight()
      		love.graphics.draw(sprite, centerX, centerY, 0, 1, 1, width / 2, height / 2)
      	end

      end

      love.graphics.pop()
   end

   love.graphics.translate(0,-verticalOffset)
   local joints = world:getJointList()
   for index,joint in pairs(cl.chainJoints) do
      local x1,y1,x2,y2 = joint:getAnchors()
      if (x1 and x2) then
      	 local angle = angleBetween( x1, y1, x2, y2);
      	 local length = distanceBetween( x1, y1, x2, y2);
      	 local quad = love.graphics.newQuad( 0, 0, length, 6, 20, 6 )
      	 love.graphics.draw(cl.worldSprites["chain"], quad, x1, y1, angle, 1, 1)
      end
   end

end

function cl.debugWorldDraw(world)
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




local brickWall = {}

function brickWall:Spawn( x )
	self.XOffset = x;

	self.RandOffset = 64*math.random(0,3) - 64*math.random(0,3)
	self.Body1 = love.physics.newBody( _world, x, 0, "static" )
	self.Height1 = 256+self.RandOffset
	local shape = love.physics.newRectangleShape(  0, self.Height1/2, 64, self.Height1, 0 )
	self.Fixture1 = love.physics.newFixture(self.Body1, shape)

	self.Body2 = love.physics.newBody( _world, x, 0, "static" )
	self.Height2 = SCREENHEIGHT
	self.YOffset = self.Height1+(125+math.random(0,2)*25) + (SCREENHEIGHT/2)
	local shape = love.physics.newRectangleShape(  0, self.YOffset, 64, self.Height2, 0 )
	self.Fixture2 = love.physics.newFixture(self.Body2, shape)

	self.Texture = love.graphics.newImage("brick32.png")
	self.maxX1 = 2
  	self.maxY1 = math.ceil(self.Height1 / 32)
  	local size = self.maxX1 * self.maxY1

  	self.maxX2 = 2
  	self.maxY2 = math.ceil(self.Height2 / 32)
  	local size = self.maxX2 * self.maxY2
end

function brickWall:New()
      o = {}   -- create object if user does not provide one
      setmetatable(o, self)
      self.__index = self
      return o
end

function brickWall:drawSprites1( )

  -- Set up (but don't draw) our images in a grid
  for y = 0, self.maxY1 do
    for x = 0, self.maxX1-1 do
      -- Convert our x/y grid references to x/y pixel coordinates
      local xPos = self.XOffset - 32 + (x * 32)
      local yPos = y * 32
 
      -- Add the image we previously set to this point
      love.graphics.draw( self.Texture, xPos, yPos )
    end
  end

end

function brickWall:drawSprites2( )


 
  -- Set up (but don't draw) our images in a grid
  for y = 0, self.maxY2 do
    for x = 0, self.maxX2-1 do
      -- Convert our x/y grid references to x/y pixel coordinates
      local xPos = self.XOffset - 32 + (x * 32)
      local yPos = self.YOffset - (self.Height2/2) + y * 32
 
      -- Add the image we previously set to this point
     love.graphics.draw( self.Texture, xPos, yPos )
    end
  end

end

function brickWall:Draw()
  -- Draw the spriteBatch with only one call!

  love.graphics.setColor(255,255,255)
  self:drawSprites1( )
  self:drawSprites2( )


end

function brickWall:Destroy()
	table.remove( cl.enemies, table.indexOf( cl.enemies, self ) );
end


function brickWall:IsHard()
	return false;
end

table.insert(cl.EnemyList, brickWall) 

local beachBall = {}

function beachBall:New()
 	o = {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function beachBall:Spawn( x )
	self.XOffset = x
	self.Body = love.physics.newBody( _world, x, 0, "dynamic" )
	local x1, y1 = self.Body:getWorldCenter()
	local firstCarPosX, firstCarPosY = cl.FirstCar:getWorldCenter();

	local angle = angleBetween( x1, y1, firstCarPosX, firstCarPosY);
	local vx, vy = angleVector( angle );
	self.Body:applyLinearImpulse( vx*1000, vy*1000 ) 
	local shape = love.physics.newCircleShape( 12 )
	fallingObject:play()
	self.Fixture = love.physics.newFixture(self.Body, shape)
	self.Fixture:setUserData( "beachball");

end

function beachBall:Draw( )
	local x1, y1 = self.Body:getWorldCenter()

	self.XOffset = x1

end

function beachBall:Destroy()
	table.remove( cl.enemies, table.indexOf( cl.enemies, self ) );
end

function beachBall:IsHard()
	return false;
end
table.insert(cl.EnemyList, beachBall);

local crateBox = {}

function crateBox:New()
 	o = {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function crateBox:Spawn( x )
	self.XOffset = x
	self.Body = love.physics.newBody( _world, x, 0, "dynamic" )
	local x1, y1 = self.Body:getWorldCenter()
	local firstCarPosX, firstCarPosY = cl.FirstCar:getWorldCenter();

	local angle = angleBetween( x1, y1, firstCarPosX, firstCarPosY);
	local vx, vy = angleVector( angle+.25 );
	self.Body:applyLinearImpulse( vx*500, vy*500 ) 
	self.Body:setAngularVelocity( math.random(-math.pi*2, math.pi*2) );
	local shape = love.physics.newRectangleShape( 0, 0, 32, 32, 0 )
	fallingObject:play()
	self.Fixture = love.physics.newFixture(self.Body, shape)
	self.Fixture:setDensity(6);
	self.Fixture:setUserData( "crate");

end

function crateBox:Draw( )
	local x1, y1 = self.Body:getWorldCenter()

	self.XOffset = x1

end

function crateBox:Destroy()
	table.remove( cl.enemies, table.indexOf( cl.enemies, self ) );
end

function crateBox:IsHard()
	return false;
end

table.insert(cl.EnemyList, crateBox);


local randomTrack = {}

function randomTrack:New()
	o = {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function randomTrack:Spawn( x )
	self.XOffset = x
	if (cl.RandomProductionSpeed == true) then self:Destroy() return; end
	cl.RandomProductionSpeed = true;
	self.Font = love.graphics.newImageFont("Courier New20pt.png", " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~");
end

function randomTrack:Draw( )
	if self.Destructed then return; end
	love.graphics.setColor( 255, 0, 0, 255 )
	
	love.graphics.setFont(self.Font)

	local w = love.graphics.getWidth()

	love.graphics.printf("Bumpy Track Ahead!\nCareful!", cl.XScroll, 100, w, "center");

	love.graphics.setColor( 255, 255, 255, 255 )

	
end

function randomTrack:Destroy()
	cl.RandomProductionSpeed = false;
	self.Destructed = true;
	table.remove( cl.enemies, table.indexOf( cl.enemies, self ) );
end

function randomTrack:IsHard()
	return false;
end

table.insert(cl.EnemyList, randomTrack);

local reversedMouse = {}

function reversedMouse:New()
	o = {}   -- create object if user does not provide one
    setmetatable(o, self)
    self.__index = self
    return o
end

function reversedMouse:Spawn( x )
	self.XOffset = x
	if (cl.reversedMouse == true) then self:Destroy() return; end
	cl.reversedMouse = true;
	self.Font = love.graphics.newImageFont("Courier New20pt.png", " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~");
end

function reversedMouse:Draw( )
	if self.Destructed then return; end
	love.graphics.setColor( 255, 0, 0, 255 )

	love.graphics.setFont(self.Font)

	local w = love.graphics.getWidth()

	love.graphics.printf("Reverse Mouse!\nUpside down!", cl.XScroll, 50, w, "center");

	love.graphics.setColor( 255, 255, 255, 255 )

end

function reversedMouse:Destroy()
	cl.reversedMouse = false;
	self.Destructed = true;
	local mouseX, mouseY = love.mouse.getPosition( )
	love.mouse.setPosition( mouseX, cl.SmoothMouseY );
	table.remove( cl.enemies, table.indexOf( cl.enemies, self ) );
end


function reversedMouse:IsHard()
	return true;
end

table.insert(cl.EnemyList, reversedMouse);
