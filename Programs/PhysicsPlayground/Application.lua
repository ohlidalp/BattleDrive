--[[
________________________________________________________________________________

 Physics Playground, a BattleDrive game
________________________________________________________________________________

--]]

------------------------------- Configuration ----------------------------------
local config = {
	-- world's gravity
	gravityX = 0;
	gravityY = 0;

	---- Phys viewport settings ----
	physCam = {
		-- scale in pixels
		x = 100;
		y = 100;
		w = 300;
		h = 300;
	};
	rootPath        = "mod_test/";
	pixelsInB2Meter = 50,
	helpColor                    = {0,255,255,255}; -- Also debug console.
	helpBgColor                  = {0,0,0,150};
	-- tile size
	tileW = 499;--500;
	tileH = 349;--350;

};
-- Game map size. Physics world size is computed from this.
config.mapW = config.tileW*10;
config.mapH = config.tileH*10;

--------------------------------- Controls -------------------------------------

local controls = {
	mainCamera = {
		goDown  = "down",
		goUp    = "up",
		goLeft  = "left",
		goRight = "right",
		toggleUseCustomRenderers = "c"
	},
	newExtraGfxCam  = "n",
	newPhysCam      = "p",
	openTestWindow  = "t",
	openSpawnWindow = "m",
	reset           = "r",
	newMouseJoint   = "l",
	units = {
		spawnBall = love.key_b;
		spawnPrism = love.key_h;
		spawnTurretStand = love.key_u;
		spawnBlasterTurret = love.key_t;
	},
	hover = {
		goLeft = love.key_a;
		goRight = love.key_d;
		goForward = love.key_w;
		goBackward = love.key_s;
	};

};

----------------------------------- Utils --------------------------------------

local Rectangle = {
	__concat = function( op1, op2 )
		if( type(op1) == "string" or type(op1) == "number" ) then
			return op1.."pos"..op2.pos.." size["..op2.w..","..op2.h.."]";
		else
			return "pos"..op1.pos.." size["..op1.w..","..op1.h.."]"..op2;
		end;
	end;
	__index = Rectangle;
};

local newVector = function( _x, _y  )
	return setmetatable(
			{
				x=_x,
				y=_y
			},
			Vector
		);
end

local newRectangle = function( _x, _y, _w, _h )
	return setmetatable(
			{
				absolutePos = newVector( _x, _y ),
				w = _w,
				h = _h
			},
			Rectangle
		);
end

---- XYMover - class which calls registered function to move an object
local XYMover = {};
XYMover.__index = XYMover;

local function newXYMover( _accX, _accY, _slowX, _slowY, _maxX, _maxY, _moveObject )
	return setmetatable(
		{
			acceleration = {x=_accX,y=_accY};--{ x=150,y=150},
			slowdown = {x=_slowX,y=_slowY};--{ x=166,y=166 },
			maxSpeed = {x=_maxX, y=_maxY};--{ x=222,y=222 },
			speed = newVector( 0,0 ),
			moveObject = _moveObject;
			-- Movement attributes are now in the root
			goLeft=false, goRight=false, goUp=false, goDown=false,
		},
		XYMover);
end

XYMover.move = function( self, elapsed )
	local signs = newVector( self.speed.x > 0 and 1 or -1, self.speed.y > 0 and 1 or -1 );

	if( self.goLeft ~= self.goRight ) then
		self.speed.x = self.speed.x + ( elapsed*self.acceleration.x * ( self.goLeft==true and -1 or 1 ) );
		if math.abs( self.speed.x ) > self.maxSpeed.x then self.speed.x = self.maxSpeed.x*signs.x; end;
	elseif self.speed.x ~= 0 then
		self.speed.x = self.speed.x + ( elapsed*self.slowdown.x * (self.speed.x<0 and 1 or -1) );
		if signs.x ~= (self.speed.x > 0 and 1 or -1) then self.speed.x = 0 end;
	end

	if( self.goUp ~= self.goDown ) then
		self.speed.y = self.speed.y + ( elapsed*self.acceleration.y * (self.goUp==true and -1 or 1) );
		if(math.abs(self.speed.y) > self.maxSpeed.y) then self.speed.y = self.maxSpeed.y*signs.y end;
	elseif self.speed.y ~= 0 then
		self.speed.y = self.speed.y + ( elapsed*self.slowdown.y * (self.speed.y<0 and 1 or -1) );
		if signs.y ~= (self.speed.y > 0 and 1 or -1) then self.speed.y = 0 end;
	end;
	self.moveObject( self.speed.x*elapsed, self.speed.y*elapsed );
end;

-- A function which draws X into a BDGUI sheet. Made for use with sheet_drawExtra function.
local function drawXIntoSheet( self )
	local origWidth = love.graphics.getLineWidth();

	love.graphics.setColor( 255,0,0,255 );
	love.graphics.setLineWidth( 2 );
	love.graphics.line( self.absolutePos.x, self.absolutePos.y,
			self.absolutePos.x+self.w, self.absolutePos.y+self.h );
	love.graphics.line( self.absolutePos.x+self.w, self.absolutePos.y,
			self.absolutePos.x, self.absolutePos.y+self.h );

	love.graphics.setLineWidth(origWidth);
end;



------------------------------------ App ---------------------------------------

local Application = {};
Application.__index = Application;
Application.__tostring = function()
	return "BattleDrive Game: Physics Playground";
end

--------------------------------------------------------------------------------
-- KeyPressed LOVE callback
--------------------------------------------------------------------------------
function Application:keyPressed(key, unicode)
	-- Main camera movement and properties
	local keys = self.controls;
	local camKeys = keys.mainCamera;
	local camMover = self.mainCameraMover;
	local Mod = self;
	if     key == camKeys.goUp    then camMover.goUp    = true; return;
	elseif key == camKeys.goDown  then camMover.goDown  = true; return;
	elseif key == camKeys.goLeft  then camMover.goLeft  = true; return;
	elseif key == camKeys.goRight then camMover.goRight = true; return;
	elseif key == camKeys.toggleUseCustomRenderers  then
		self.mainCamera:setUseCustomRenderers(not self.mainCamera:getUseCustomRenderers()); return;
	elseif( keys.openSpawnWindow == key and Mod.ui.spawnPanel==nil ) then
		self.ui.openSpawnPanel(); return;
	-- Opening new cameras
	elseif( Mod.controls.newExtraGfxCam == key ) then
		self:addExtraGfxCamWindow(100,100,400,300); return;
	elseif( Mod.controls.newPhysCam == key ) then
		self:addPhysCamWindow(
			config.physCam.x,
			config.physCam.y,
			config.physCam.w,
			config.physCam.h);
		return;
	--elseif( Mod.controls. == key ) then  return;

	elseif( Mod.controls.reset == key ) then love.system.restart(); return;
	-- elseif( Mod.controls. == key ) then self:(); return;

	-- Hover
	elseif( Mod.controls.hover.goLeft == key ) then hover.drive.goLeft=true; return;
	elseif( Mod.controls.hover.goRight == key ) then hover.drive.goRight=true; return;
	elseif( Mod.controls.hover.goForward == key ) then hover.drive.goForward=true; return;
	elseif( Mod.controls.hover.goBackward == key ) then hover.drive.goBackward=true; return;
	end;

	-- Exit
	if key == "escape" then
		print(" ==== Physics Playground: Exit ==== ");
		self:exit();
		return;
	end

	-- Spawning --
	local mouseMapX, mouseMapY = 0,0;
	if( self.physViewportWithCursor) then
		local mouseWorldX, mouseWorldY = self.physViewportWithCursor:computeWorldPos(
					love.mouse.getX(), love.mouse.getY());
		mouseMapX, mouseMapY =
			Mod.mapConverter:b2MetersToPixels(mouseWorldX, mouseWorldY);
	else
		mouseMapX, mouseMapY
			= Mod.mainCamera:computeMapPos(love.mouse.getX(),love.mouse.getY());
	end;

	if(key == self.controls.units.spawnBall ) then
		--print("====spawn ball====\nmouseMapX",mouseMapX,"mouseMapY",mouseMapY);
		self:addEntity( self.units.spawnBall(
			mouseMapX, mouseMapY, 0, Mod.settings.spawnUnitTeam ));
	elseif(key==self.controls.units.spawnPrism) then
		self:addUnit( self.units.spawnPrism(
			mouseMapX, mouseMapY, 0, Mod.settings.spawnUnitTeam ));
	elseif(key==self.controls.units.spawnTurretStand) then
		self:addEntity( self.units.spawnTurretStand(
			mouseMapX, mouseMapY, 0, Mod.settings.spawnUnitTeam ));
	elseif(key==self.controls.units.spawnBlasterTurret)then
		--print("spawn blaster turret");
		self:addUnit( self.units.spawnBlasterTurret(
			mouseMapX, mouseMapY, 0, Mod.settings.spawnUnitTeam) );

	end
end

--------------------------------------------------------------------------------
-- KeyReleased LOVE callback
--------------------------------------------------------------------------------
function Application:keyReleased(key)
	local Mod = self;
	local game = self;
	-- Main camera movement
	    if key == game.controls.mainCamera.goUp then self.mainCameraMover.goUp = false; return;
	elseif key == game.controls.mainCamera.goDown then self.mainCameraMover.goDown = false; return;
	elseif key == game.controls.mainCamera.goLeft then self.mainCameraMover.goLeft = false; return;
	elseif key == game.controls.mainCamera.goRight then self.mainCameraMover.goRight = false; return;

	-- Hover
	elseif( Mod.controls.hover.goLeft == key ) then hover.drive.goLeft=false; return;
	elseif( Mod.controls.hover.goRight == key ) then hover.drive.goRight=false; return;
	elseif( Mod.controls.hover.goForward == key ) then hover.drive.goForward=false; return;
	elseif( Mod.controls.hover.goBackward == key ) then hover.drive.goBackward=false; return;

	end;
end;

function Application:mouseMoved( newX, newY, oldX, oldY )
	self.desk:mouseMoved( newX, newY, oldX, oldY );
	-- If there's mouse joint, update it
	if( self.physViewportWithCursor and self.mouseJointHolder.joint )then
		self.mouseJointHolder.joint:setTarget(
				self.physViewportWithCursor:computeWorldPos(newX,newY));
	end;
end;

function Application:mousePressed( x,y,button )
	self.desk:mousePressed( x,y,button );
	if(self.physViewportWithCursor and button==self.controls.newMouseJoint )then
		local worldX,worldY = self.physViewportWithCursor:computeWorldPos(x,y);
		local body = self.physViewportWithCursor:getBodiesOnPoint(worldX,worldY);
		if(body)then
			self.mouseJointHolder.joint = love.physics.newMouseJoint( body,worldX,worldY );
		end;
	end;
end;

function Application:mouseReleased( x,y,button )
	self.desk:mouseReleased( x,y,button );
	-- If there's mouse joint, delete it
	if( self.mouseJointHolder.joint )then
		self.mouseJointHolder.joint:destroy();
		self.mouseJointHolder.joint=nil;
	end;
end;

--------------------------------------------------------------------------------
-- Update LOVE callback
-- @param dt DeltaTime - time since last update in seconds.
--------------------------------------------------------------------------------
function Application:update(dt)
	local elapsed = dt;
	local Mod = self;
	local console = self.dbgTextArea;
	console:printLn("FPS:"..love.timer.getFPS());
	self.world:update(elapsed);

	-- Move camera
	self.mainCameraMover:move( elapsed );

	-- Update entities
	for index, e in ipairs(self.entities) do
		if e.update then
			e:update(elapsed);
		end;

		if(e.dead)then
			self:removeEntity(e);
		end;
		--console:printLn("<grob> z:",grob.z);
		--console:printLn("<grob> angle:",grob.angle);
	end;

	--hover:move(elapsed);
	--[[
	console:printLn(
		"Speed:"..hover.body:getVelocityLocalPoint(0,0)
		.." spin:"..hover.body:getSpin());
	for index, prism in ipairs(Mod.prisms) do
		console:printLn("<main> prism"..index.." angle:"..prism.body:getAngle());
	end;
	--]]
	console:printLn("Main camera grobs:"
		..self.mainCamera:getNoVisibleTowerGrobs()+self.mainCamera:getNoVisibleShadowGrobs()
		.."/"..self.mainCamera:getNoTowerGrobs()+self.mainCamera:getNoShadowGrobs());

	if(self.physViewportWithCursor)then
		self.dbgMousePointedBody =
			self.physViewportWithCursor:getBodiesOnPoint(
				self.physViewportWithCursor:computeWorldPos(love.mouse.getX(),love.mouse.getY()));
	end;
	--[ [ Cursor body lookup test
	-- This displays which physics body is currently pointed with mouse
	console:printLn("Pointed body:",self.dbgMousePointedBody);
	--]]

	--[ [ Mouse joint
	if(self.mouseJointHolder.joint)then
		local x1,y1,x2,y2 = self.mouseJointHolder.joint:getAnchors();
		console:printLn("Mouse joint: from",x1,y1,"to",x2,y2);
	end;
	--]]

	--[ [ Test function PhysCamera:computeWorldPos(screenX, screenY)
	if(self.physViewportWithCursor)then
		console:printLn(
			self.physViewportWithCursor:computeWorldPos(love.mouse.getX(),love.mouse.getY()));
	end;
	--]]

	--[ [ DEBUG
	console:printLn("New units team:"..Mod.settings.spawnUnitTeam.name);
	--]]
end

--------------------------------------------------------------------------------
-- Handle a LOVE event
-- @param e string event type (love.event.Event enum)
-- @param a mixed event attribute (depends on event type)
-- @param b mixed event attribute (depends on event type)
-- @param c mixed event attribute (depends on event type)
-- @param d mixed event attribute (depends on event type)
--------------------------------------------------------------------------------
function Application:handleEvent(e,a,b,c,d)
	if     e == "kp" then
		self:keyPressed(a,b);
	elseif e == "kr" then
		self:keyReleased(a);
	elseif e == "mp" then
		self:mousePressed(a,b,c);
	elseif e == "mr" then
		self:mouseReleased(a,b,c);
	end
end

--------------------------------------------------------------------------------
-- Tell this game (externally or internally) to exit
--------------------------------------------------------------------------------
function Application:exit()
	self.core:endGame();
end

--------------------------------------------------------------------------------
-- Terminate and clean up this game. Should be called externally after exit.
--------------------------------------------------------------------------------
function Application:cleanup()

end



function Application:removePhysCamWindow( indexOrPointer )
	print("Application:removePhysCamWindow() arg:"..tostring(indexOrPointer));
	if( type(indexOrPointer)=="table" ) then
		BDT.tableRemoveByValue(self.physCamWindows, indexOrPointer);
	else
		index = index or #self.physCamWindows;
		table.remove( self.physCamWindows, index );
	end;
end

function Application:addPhysCamWindow( _x, _y, _w, _h )
	local window = BDT_GUI.shorthands.openEquippedWindow( self.desk, _x, _y, _w, _h );
	local app = self;
	local closePhysCamWinFunction = function(self)
		app:removePhysCamWindow(window);
		window:detach();
	end;
	window.buttons.close.onMouseUp:add(closePhysCamWinFunction);
	local viewport
		= window:newSheet( 15, 15, _w-30, _h-30, BDT_GUI.arrange.fixedPosLinkedScale );
	--viewport.parentChanged = sheet_parentChangedLinkedScale;
	local camera = BDT_PhysCamera:newPhysCamera( 5, 0.00000000001, 0.05, 0.05, {x=0,y=0}, viewport,
		self.shapes, self.converter, self.mouseJointHolder );
	window.camera = camera;
	viewport.onMouseDown:add(
		function( sheet, x,y,button )
			--print("<viewport onmousedown>, button ",button,"wheelup",love.mouse_wheelup);
			if( button == love.mouse_wheelup  ) then
				--print("<viewport> zoomin");
				camera:zoomIn();
			elseif( button == love.mouse_wheeldown ) then
				--print("<viewport> zoomout");
				camera:zoomOut();
			end;
		end );
	viewport.onDrag:add(
		function(sheet,newX,newY,oldX,oldY, buttons)
			if(buttons.right) then
				camera:moveOnWorld( oldX-newX, oldY-newY );
			end;
		end );
	viewport.onMouseOver:add( function() self.physViewportWithCursor = camera end );
	viewport.onMouseOut:add( function() self.physViewportWithCursor = false end );
	viewport.draw = function( self ) camera:draw() end;
	table.insert( self.physCamWindows, 1, window );
end

function Application:removeExtraGfxCamWindow( indexOrPointer )
	--print("App:removeExtraGfxCamWindow() indexOrPointer:"..tostring(indexOrPointer));
	if type(indexOrPointer) == "table" then
		BDT.tableRemoveByValue(self.extraGfxCamWindows,indexOrPointer);
	else
		index = index or #self.extraGfxCamWindows;
		table.remove( self.extraGfxCamWindows, index );
	end;
end;

function Application:addExtraGfxCamWindow( _x, _y, _w, _h )
	local window = BDT_GUI.shorthands.openEquippedWindow( self.desk, _x, _y, _w, _h );
	local app = self;
	window.closeFunction = function(self)
		app:removeExtraGfxCamWindow(window);
		self.parent:removeSheet(self);
	end;
	local viewport = window:newSheet(
		15, 15, _w-30, _h-30,
		BDT_GUI.arrange.fixedPosLinkedScale );
	window.camera = bd.newGfxCamera( Mod.map, {x=0;y=0}, viewport );
	viewport.draw = function() window.camera:draw() end;
	viewport.onDrag:add(
		function( self, newX, newY, oldX, oldY )
			window.camera:moveOnMap( oldX-newX, oldY-newY )
		end
	);
	window.camera:addGrobs(Mod.towerGrobs);
	window.camera:addGrobs(Mod.towerGrobs);
	table.insert( self.extraGfxCamWindows, 1, window );
end;

--------------------------------------------------------------------------------
-- Puts supplied grob into the mod's grob list, all gfx cameras and other optinal tables.
--------------------------------------------------------------------------------
function Application:distributeTowerGrob(grob)
	if not grob then
		return;
	end
	table.insert(self.towerGrobs, grob);
	self.mainCamera:addTowerGrob(grob);
	for index, window in ipairs(self.extraGfxCamWindows) do
		window.camera:addTowerGrob(grob);
	end
end

--------------------------------------------------------------------------------
-- Removes supplied grob from the mod's grob list, all gfx cameras and other optinal tables.
--------------------------------------------------------------------------------
function Application:removeTowerGrob(grob)
	if not grob then
		return;
	end
	bd.table.removeByValue(self.towerGrobs,grob);
	self.mainCamera:removeTowerGrob(grob);
	for index, window in ipairs(self.extraGfxCamWindows) do
		window.camera:removeTowerGrob(grob);
	end
end

--- Puts supplied grob into the mod's grob list, all gfx cameras and other optinal tables.
function Application:distributeShadowGrob(grob)
	if not grob then
		return;
	end
	table.insert(self.shadowGrobs, grob);
	self.mainCamera:addShadowGrob(grob);
	for index, window in ipairs(self.extraGfxCamWindows) do
		window.camera:addShadowGrob(grob);
	end
end

--- Removes supplied grob from the mod's grob list, all gfx cameras and other optinal tables.
function Application:eraseShadowGrob(grob)
	if not grob then
		return;
	end
	self.mainCamera:removeShadow(grob);
	BDT.tableRemoveByValue(self.shadowGrobs, grob);
	for index, window in ipairs(self.extraGfxCamWindows) do
		window.camera:removeShadow(grob);
	end
end

--- Introduces a new entity into the game.
--  Adds it into mod's entity list, distributes it's grobs and physical shapes.
function Application:addEntity(e)
	local table_insert = table.insert;
	if e.getTowerGrob then
		self:distributeTowerGrob(e:getTowerGrob());
	end
	if e.getShadowGrob then
		self:distributeShadowGrob(e:getShadowGrob());
	end
	if e.getMovingCircles then
		table_insert(self.shapes.movingCircles, e:getMovingCircles());
	end
	if e.getMovingPolys then
		table_insert(self.shapes.movingPolys, e:getMovingPolys());
	end
	if e.getStaticCircles then
		table_insert(self.shapes.staticCircles, e:getStaticCircles());
	end
	table_insert(self.entities, e);
end

--- Removes an entity from the game
--  Erases it's grobs from all cameras and erases it's phys. shapes from shape lists.
function Application:removeEntity(e)
	local tableRm = BDT.tableRemoveByValue;
	self:eraseTowerGrob(e:getTowerGrob());
	if e.getShadowGrob then
		self:eraseShadowGrob(e:getShadowGrob());
	end
	if e.getMovingCircles then
		tableRm(self.shapes.movingCircles, e:getMovingCircles());
	end
	if e.getMovingPolys then
		tableRm(self.shapes.movingPolys, e:getMovingPolys());
	end
	if e.getStaticCircles then
		tableRm(self.shapes.staticCircles, e:getStaticCircles());
	end
	tableRm(self.entities, e);
end

--- Introduces a new combat unit (specialized entity) in the game
function Application:addUnit(u)
	self:addEntity(u);
	table.insert(self.units,u);
end;

--- Removes a combat unit (specialized entity) from the game
function Application:removeUnit(u)
	self:removeEntity(u);
	BDT.tableRemoveByValue(self.units,u);
end;

function Application:draw()
	self.mainCamera:draw();
	self.desk:draw();
end;

--------------------------------------------------------------------------------
-- Game constructor
--------------------------------------------------------------------------------
return function(core)
	local love_graphics = love.graphics;
	local love_graphics_newImage = love_graphics.newImage;
	local love_physics = love.physics;
	local love_physics_newPolygonShape = love_physics.newPolygonShape;
	local bdConfig = core:getConfig();
	local grDir = bdConfig.graphicsDir;

	local teams = {
		player = {
			name = "Player";
		};
		top = {
			name = "Top";
		};
		bottom = {
			name = "Bottom";
		};
	};
	teams.top.enemies = {teams.bottom};
	teams.bottom.enemies = {teams.top};
	teams.player.enemies = {};

	local settings = {
		showHpBars = false;
		spawnUnitTeam = teams.player;
	};

	local tileset = {};
	tileset[1]=love_graphics_newImage(grDir.."/Grass_500x350.png");
	tileset[2]=love_graphics_newImage(grDir.."/Grass_Greener_500x350.png");
	tileset[3]=love_graphics_newImage(grDir.."/Pavement_500x350.png");

	-- Shape list
	local shapes = {
		staticPolys = {};
		staticCircles = {};
		movingPolys = {};
		movingCircles = {};
		sensorPolys = {};
		sensorCircles = {};
	};

	-- Physics world
	local worldW,worldH = config.mapW, config.mapH;--mapConverter:pixelsToB2Meters(config.mapW, config.mapH);
	local world, ground, bpTop, bpBottom, bpLeft, bpRight
		= BDT_Instant.createFencedPhysWorld(
			0,0, worldW, worldH, config.pixelsInB2Meter,
			config.gravityX, config.gravityY, true );
	shapes.borderPolys = {
		left = bpLeft;
		right = bpRight;
		top = bpTop;
		bottom = bpBottom;
	};
	print("DBG love.phys.World created");

	-- Test shapes
	shapes.staticPolys.tlRect = love_physics_newPolygonShape(
			ground,  0,0,  20,15,  15,20 );
	print("DBG tlRect created");
	shapes.staticPolys.brRect = love_physics_newPolygonShape(
			ground, worldW, worldH,
			worldW - 20, worldH - 15,
			worldW - 15, worldH - 20 );
	print("DBG brRect created");

	-- Map
	local map = BDT_Map.newMap(
		config.mapW, config.mapH, -- parcel size
		1,1, -- map size in parcels
		tileset, -- tileset
		config.tileW, config.tileH ); -- tile size
	map.pixelWidth, map.pixelHeight = config.mapW, config.mapH;--OLD map:getPixelSize();
	BDT_Instant.checkerMap( map, 1, 2, 3 );

	-- Main camera
	local mainCameraViewport = newRectangle( 10,10,780,580 );
	local mainCamera = BDT_GfxCamera.newGfxCamera(
		map,
		newVector(map.pixelWidth/2, map.pixelHeight/2),
		mainCameraViewport, BDT_Grob.zInsertSort );
	-- FIXME mainCamera.customDrawingFunctions:add(BDT_AI.drawTargetingLines);

	-- Main camera mover (for controlling by keyboard)
	local mainCameraMover = newXYMover( 150,150,  166,166,  288,288,
		function(x,y)
			mainCamera:moveOnMap(x,y)
		end );



	-- Converters
	local mapConverter = BDT_Common.newMapConverter();
	local converter = BDT_Common.newLinearConverter();





	local desk = BDT_GUI.newDesk();

	local physCamWindows = {};

	-- Extra gfx cameras
	local extraGfxCamWindows = {};

	-- Debug console
	local sheet = desk:newSheet(0,0,400,300);
	desk:removeSheet(sheet);
	local rend = BDT_GUI.newSheetRenderer(sheet);
	rend:getPalette():setColor("inactiveFill",config.helpBgColor);
	sheet:setActive(false); -- Also updates colors.
	local textArea = BDT_GUI.newSheetTextArea("Hello debug console!");
	rend:addContent(textArea);
	textArea:setColor(config.helpColor);

	return setmetatable({
		core = core;
		gameDir = gameDir;
		converter = converter;
		mapConverter = mapConverter;
		pi4 = math.pi*4;
		-- Tells which phys camera the cursor is in, if any.
		-- It contains a reference to the camera, or false if it's not in any
		physViewportWithCursor = false;
		-- Same meaning, but references a graphical viewport
		gfxViewportWithCursor = false;
		mouseJointHolder = {}; -- table for shared access to the mouse joint
		towerGrobs = {};
		shadowGrobs = {};
		entities = {};
		teams = teams;
		settings = settings;
		controls = controls;
		map = map;
		mainCameraViewport = mainCameraViewport;
		mainCamera = mainCamera;
		mainCameraMover = mainCameraMover;
		shapes = shapes;
		world = world;
		ground = ground;
		physCamWindows = physCamWindows;
		extraGfxCamWindows = extraGfxCamWindows;
		dbgTextArea = textArea;
		dbgSheet = sheet;
		desk = desk;
		dbgMousePointedBody = false;
	}, Application);
end
