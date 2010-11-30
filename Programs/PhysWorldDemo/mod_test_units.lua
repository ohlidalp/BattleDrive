-- mod test units

--[[
"Entity" is some game-logic related object, like a tree or building.
"Unit" is specialized entity, like tank or turret.
Technically, they're the same at the moment.

== Entity ==
Attributes:
	+ type --string naming the unit type, like "Blaster Turret";
	+ team
Methods:
	+ getTowerGrob()
	+ getShadowGrob()
	+ getStaticCircles()
	+ getMovingCircles()
	+ getMovingPolys()
	+ getMapPos()
	+ getShade()
	
	
Note: a spawning function convention is: 
	spawnSomething( x, y, angle, team, ...)
	x and y is the unit's map position in pixels.
	angle is the unit's angle in degrees, 0 being straight down
--]]

local function shapeData_getPosition(self)
	return self.body:getPosition();
end;

local function shapeData_staticShape_getPosition(self)
	return self.staticX, self.staticY; 
end;

return function(Mod, bd, bdx, bdgui, bdguix) -- Module

Mod.units = {};

Mod.units.workshops = {
	--print("=ball workshop =");
	ball = bd.grob.newWorkshop( 'graphics/ball/ballGrob.lua' );
	--print("=ball shadow workshop =");
	ballShadow = bd.grob.newWorkshop( 'graphics/ball/ballShadowGrob.lua' );
	prism = bd.grob.newWorkshop('graphics/prism/prismTowerGrob.lua');
	prismShadow = bd.grob.newWorkshop('graphics/prism_shadow/PrismShadowGrob.lua');
	turretStand = bd.grob.newWorkshop("graphics/turret/stand/TurretStandGrob.lua"); 
	turretStandShadow = bd.grob.newWorkshop("graphics/turret/shadow/TurretShadowGrob.lua");
	gun = bd.grob.newWorkshop("graphics/turret/gun/gunTowerGrob.lua");
};

---------------------------------- Ball -----------------------------------
do -- Closure for Ball
	
	local Ball = {};
	Ball.__index = Ball;
	Ball.type = "Ball";
	
	Mod.units.spawnBall =  function(x,y,angle,team)
		local ball = {}; -- entity
		-- Graphics
		ball.grob = Mod.units.workshops.ball:buildRoot(x,y);
		--print("spawnBall: grob.spriteCount:",ball.grob.spriteCount);
		ball.shadow = Mod.units.workshops.ballShadow:buildRoot(x,y);
		ball.grob:attachLinkedGrob(ball.shadow);
		ball.grob.unit = ball;
		
		-- Physics
		ball.body = love.physics.newBody( 
			Mod.world, Mod.mapConverter:pixelsToB2Meters(x,y) );
		ball.circle = love.physics.newCircleShape(--FIXME:hardcoding
			ball.body,Mod.converter:pixelsToB2Meters(26));
		ball.circle:setData({
			body=ball.body;
			getPosition = shapeData_getPosition;
		});
		ball.body:setMassFromShapes();
		ball.team = team;
		ball.grob.angle=angle or ball.grob.angle;
		
		return setmetatable(ball,Ball);
	end;
	
	function Ball:update()
		if self.body:isSleeping() == false then
			self.grob:setAngleDegrees( self.body:getAngle() );
			self.grob:setMapPos(Mod.mapConverter:b2MetersToPixels(self.body:getPosition()));
			self.grob:updateZ();
		end;
	end;
	-- Entity functions
	function Ball:getTowerGrob() return self.grob; end;
	function Ball:getMovingCircles() return self.circle; end;
	function Ball:getShadowGrob() return self.shadow; end;
	function Ball:getMapPos() return self.grob:getMapPos();	end;
	function Ball:getShade() return self.grob:getShade(); end;
	
end; -- Closure for Ball

----------------------------------- Prism --------------------------------------
do -- Closure
	local Prism = {};
	Prism.__index = Prism;
	Prism.type = "Prism";
	
	function Mod.units.spawnPrism(x,y,angle,team)
		local prism = setmetatable({},Prism);
		prism.team = team;
		
		-- Graphics
		prism.grob = Mod.units.workshops.prism:buildRoot(x,y);
		prism.grob:setAngleDegrees(angle);
		prism.grob.unit = prism;
		prism.shadow = Mod.units.workshops.prismShadow:buildRoot(x,y);
		prism.grob:attachLinkedGrob(prism.shadow);
		
		-- Physics
		prism.body = love.physics.newBody(
			Mod.world, Mod.mapConverter:pixelsToB2Meters(x,y));
		prism.shape = love.physics.newPolygonShape( 
			prism.body, -- FIXME: hardcoding!!
			Mod.converter:pixelsToB2Meters(-23,-23,  23,-23,  23,23,  -23,23));
		prism.body:setMassFromShapes();
		-- Back reference
		prism.shape:setData({body=prism.body});
		
		return prism;
	end;
	
	-- Update method
	function Prism:update()
		if self.body:isSleeping() == false then
			self.grob:setAngleDegrees( self.body:getAngle() );
			self.grob:setMapPos( Mod.mapConverter:b2MetersToPixels(self.body:getPosition()) );
			self.grob:updateZ();
			console:printLn("<prism angle> "..self.body:getAngle());
		end;
	end;
	
	function Prism:getMapPos()
		return self.grob.pos.x, self.grob.pos.y;
	end;
	
	function Prism:getTowerGrob()
		return self.grob;
	end;
	
	function Prism:getShadowGrob()
		return self.shadow;
	end;
	
	function Prism:getMovingPolys()
		return self.shape;
	end;
	
	function Prism:getShade()
		return self.grob:getShade();
	end;
	
	function Mod.units.explodePrism(prism)
		Mod:addEntity(
			Mod.graphics.newExplosionEntity(prism.pos.x, prism.pos.y));
		Mod:removeEntity(prism);
	end;
end; -- Closure for Prism

------------------------- Blaster turret ---------------------------------------

do -- Blaster turret closure

	local BlasterTurret = {};
	BlasterTurret.__index = BlasterTurret;
	BlasterTurret.name = "Blaster Turret";
	
	function Mod.units.spawnBlasterTurret(x,y,angle,team)
		if not team then error("spawnBlasterTurret: team argument is nil"); end;
		local e = {};
		-- Graphics
		e.stand = Mod.units.workshops.turretStand:buildRoot(x,y);
		e.stand.type = "Turret Stand"; -- FIXME should be part of grob spec.
		e.standShadow = Mod.units.workshops.turretStandShadow:buildRoot(x,y);
		e.stand:attachLinkedGrob(e.standShadow);
		e.stand.unit = e;
		e.gun = Mod.units.workshops.gun:buildSub();
		e.gun.type = "Blaster Cannon"; -- FIXME should be part of grob spec.
		e.stand:attachChild(e.gun,1);
		-- Physics (static circle shape)
		local worldX, worldY = Mod.mapConverter:pixelsToB2Meters(x,y);
		e.circle= -- FIXME: hardcoding!!
			love.physics.newCircleShape(
				Mod.ground,	worldX, worldY,	Mod.converter:pixelsToB2Meters(27));
		e.circle:setData({
			staticX = worldX;
			staticY = worldY;
			getPosition=shapeData_staticShape_getPosition;
		});
		-- Logic --
		-- FIXME: hardcoded range
		e.logic = bdx.newTurret( e.gun, 500, team );
		e.ai = Mod.ai.newTurretAI( e.logic, Mod.map, Mod.units );
		e.team = team;

		return setmetatable(e, BlasterTurret);
	end;
	
	function BlasterTurret:update(elapsed)
		self.ai:update(elapsed);
	end;
	
	function BlasterTurret:getTowerGrob() return self.stand; end;
	function BlasterTurret:getShadowGrob() return self.standShadow; end;
	function BlasterTurret:getStaticCircles() return self.circle; end;
	function BlasterTurret:getShade() return self.stand:getShade(); end;
	function BlasterTurret:getMapPos() return self.stand:getMapPos(); end;

end; -- Blaster turret closure

------------------------- Turret stand (obstacle) ------------------------------

do -- Turret stand block
	local Stand = {};
	Stand.__index = Stand;
	Stand.type = "Empty Turret Stand";
		
	function Mod.units.spawnTurretStand(x,y)
		-- Graphics
		local e = setmetatable({},Stand);
		e.stand = Mod.units.workshops.turretStand:buildRoot(x,y);
		e.stand.unit = stand;
		e.shadow = Mod.units.workshops.turretStandShadow:buildRoot(x,y);
		e.stand:attachLinkedGrob(e.shadow);
		
		-- Physics (static circle shape)
		local circleData = {true,true,true};
		circleData.getPosition=shapeData_staticShape_getPosition;
		circleData.staticX, circleData.staticY 
			= Mod.mapConverter:pixelsToB2Meters(x,y);
		e.circle= love.physics.newCircleShape(
				Mod.ground,
				circleData.staticX, circleData.staticY,
				Mod.converter:pixelsToB2Meters(27));-- FIXME: hardcoding!!
		e.circle:setData(circleData);
		
		return e;
	end;
	
	function Stand:getTowerGrob() return self.stand; end;
	function Stand:getShadowGrob() return self.shadow; end;
	function Stand:getStaticCircles() return self.circle; end;
	function Stand:getShade() return self.stand:getShade(); end;
	function Stand:getMapPos() return self.stand:getMapPos(); end;
end; -- Turret stand block

end; -- Module 