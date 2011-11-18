--[[
________________________________________________________________________________

 Duel game.
________________________________________________________________________________

--]]

local gameConfig = {
	playerAControls = {
		goLeftKey                    = "a";
		goRightKey                   = "d";
		goForwardKey                 = "w";
		goBackwardKey                = "s";
		turretTurnLeftKey            = "`";
		turretTurnRightKey           = "1";
		fireKey                      = "q";
		toggleFreeCamera             = "e";
	},
	playerBControls = {
		goLeftKey                    = "left";
		goRightKey                   = "right";
		goForwardKey                 = "up";
		goBackwardKey                = "down";
		turretTurnLeftKey            = ".";
		turretTurnRightKey           = "/";
		fireKey                      = "rshift";
		toggleFreeCamera             = "rctrl";
	},
	keys = {
		toggleFullscreen = "f";
	},
	tankHp = 1000,
	blasterDmg = 100,
	fullscreenW = 1024,
	fullscreenH = 768,
	statusbarH = 20,
	statusbarTextY = 17,
}

do
	local a = gameConfig.playerAControls;
	gameConfig.camAScrollKeys = {
		goLeft = a.goLeftKey,
		goRight = a.goRightKey,
		goUp = a.goForwardKey,
		goDown = a.goBackwardKey,
	};

	local b = gameConfig.playerBControls;
	gameConfig.camBScrollKeys = {
		goLeft = b.goLeftKey,
		goRight = b.goRightKey,
		goUp = b.goForwardKey,
		goDown = b.goBackwardKey,
	};
end

local DuelApp = class("DuelApp");

--------------------------------------------------------------------------------
-- KeyPressed LOVE callback
--------------------------------------------------------------------------------
function DuelApp:keyPressed(key, unicode)
	-- Exit on escape
	if key == "escape" then
		self:exit();
	elseif key == gameConfig.keys.toggleFullscreen then
		if self.isFullscreen then
			local conf = self.core:getConfig();
			if self:setVideoMode(conf.screenWidth, conf.screenHeight, false, false, 0) then
				-- print("Window mode set OK");
				self.isFullscreen = false;
			end
		else
			if self:setVideoMode(gameConfig.fullscreenW, gameConfig.fullscreenH, true, false, 0) then
				-- print("Fullscreen mode set OK");
				self.isFullscreen = true;
			end
		end
	elseif key == gameConfig.playerAControls.toggleFreeCamera then
		self.camAFree = not self.camAFree;
	elseif key == gameConfig.playerBControls.toggleFreeCamera then
		self.camBFree = not self.camBFree;
	end

	if self.camAFree then
		self.camAKeyScroller:keyPressed(key);
	else
		self.vehicleA:keyPressed(key);
	end
	if self.camBFree then
		self.camBKeyScroller:keyPressed(key);
	else
		self.vehicleB:keyPressed(key);
	end
end

--------------------------------------------------------------------------------
-- Change video mode and update interface
--------------------------------------------------------------------------------
function DuelApp:setVideoMode(w, h, fullscreen, vsync, fsaa)
	if love.graphics.setMode(w, h, fullscreen, vsync, fsaa) then
		local barH = gameConfig.statusbarH;
		-- Make 2px space between viewports
		self.camA:setViewport(0, barH, w / 2 - 1, h - barH);
		self.camB:setViewport((w / 2) + 1, barH, w / 2 - 1, h - barH);
		return true;
	else
		return false;
	end
end

--------------------------------------------------------------------------------
-- KeyReleased LOVE callback
--------------------------------------------------------------------------------
function DuelApp:keyReleased(key)
	if self.camAFree then
		self.camAKeyScroller:keyReleased(key);
	else
		self.vehicleA:keyReleased(key);
	end

	if self.camBFree then
		self.camBKeyScroller:keyReleased(key);
	else
		self.vehicleB:keyReleased(key);
	end
end

--------------------------------------------------------------------------------
-- Mouse motion callback. Not provided by LOVE, emulated in main.lua
--------------------------------------------------------------------------------
function DuelApp:mouseMoved(newX, newY, oldX, oldY)
	self.desk:mouseMoved(newX, newY, oldX, oldY);
end

--------------------------------------------------------------------------------
-- LOVE callback
--------------------------------------------------------------------------------
function DuelApp:mousePressed( x, y, button )
	self.desk:mousePressed( x, y, button );
end

--------------------------------------------------------------------------------
-- LOVE callback
--------------------------------------------------------------------------------
function DuelApp:mouseReleased( x, y, button )
	self.desk:mouseReleased( x, y, button );
end

--------------------------------------------------------------------------------
-- Update LOVE callback
-- @param dt DeltaTime - time since last update in seconds.
--------------------------------------------------------------------------------
function DuelApp:update (dt)
	self.vehicleA:update(dt);
	if self.camAFree then
		self.camAKeyScroller:update(dt);
	else
		self.camA:setMapPos(self.vehicleA:getRootGrob():getPositionXY());
	end
	self.camA:update(dt);

	self.vehicleB:update(dt);
	if self.camBFree then
		self.camBKeyScroller:update(dt);
	else
		self.camB:setMapPos(self.vehicleB:getRootGrob():getPositionXY());
	end
	self.camB:update(dt);
end

--------------------------------------------------------------------------------
-- Handle a LOVE event
-- @param e string event type (love.event.Event enum)
-- @param a mixed event attribute (depends on event type)
-- @param b mixed event attribute (depends on event type)
-- @param c mixed event attribute (depends on event type)
-- @param d mixed event attribute (depends on event type)
--------------------------------------------------------------------------------
function DuelApp:handleEvent(e,a,b,c,d)
	if e == "kp" then
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
function DuelApp:exit()
	self.core:endGame();
	print(" ==== Duel: Exit ==== ");
end

--------------------------------------------------------------------------------
-- Terminate and clean up this game. Should be called externally after exit.
--------------------------------------------------------------------------------
function DuelApp:cleanup()

end

--------------------------------------------------------------------------------
-- Game constructor
-- @param core : BDCore The main menu app object.
-- @param gameDir : string Game's directory
--------------------------------------------------------------------------------
function DuelApp:initialize(core, gameDir)

	local conf = core:getConfig();
	local tilesetDir = conf['graphicsDir'].."/Tilesets/basic/";
	local quads, img, tileW, tileH, _, _ = BDT_Map.loadTilesetDataFromFile(tilesetDir.."tileset.lua");
	local img = love.graphics.newImage(tilesetDir.."tileset.png");
	img:setFilter("nearest", "linear");
	local mapInfo = require (gameDir .. "/DuelMap.lua");
	local array, mapXTiles, mapYTiles = mapInfo[1], mapInfo[2], mapInfo[3];
	local mapW, mapH = tileW * mapXTiles, tileH * mapYTiles;
	local map = BDT_Map.newMap(
		mapW, mapH, 1, 1, img, quads, array, tileW, tileH);
	local desk = BDT_GUI.newDesk();

	-- Setup cameras
	local camW, camH = math.floor(conf.screenWidth / 2), conf.screenHeight;
	local camCenter = {x=(mapW/2)-(camW/2), y=(mapH/2)-(camH/2)};
	local camAPos = {x = mapW/4 - camW/2, y = camCenter.y}
	local camA = BDT_GfxCamera.newGfxCamera(map, camAPos);
	local camBPos = {x = (mapW/4)*3 - camW/2, y = camCenter.y}
	local camB = BDT_GfxCamera.newGfxCamera(map, camBPos);--, {w = camW, h = camH, absolutePos = {x = camW, y = 0}});
	local camAKeyScroller = BDT_Misc.XYMover:new(nil, gameConfig.camAScrollKeys, function(x, y)
			camA:moveOnMap(x, y)
		end);
	local camBKeyScroller = BDT_Misc.XYMover:new(nil, gameConfig.camBScrollKeys, function(x, y)
			camB:moveOnMap(x, y)
		end);

	-- Setup vehicles
	local tankFactory = BDT_Entities:createFactory('TheTank');
	local vehicleA = tankFactory:build(mapW / 4, mapH / 2, gameConfig.playerAcontrols);
	vehicleA:getTurntable():enableKeyboardControl(true);
	camA:addTowerGrob(vehicleA:getRootGrob());
	camB:addTowerGrob(vehicleA:getRootGrob());
	local vehicleB = tankFactory:build((mapW / 4) * 3, mapH / 2, gameConfig.playerBControls);
	vehicleB:getTurntable():enableKeyboardControl(true);
	camA:addTowerGrob(vehicleB:getRootGrob());
	camB:addTowerGrob(vehicleB:getRootGrob());

	-- Setup attributes
	self.core = core;
	self.gameDir = gameDir;
	self.map = map;
	self.camA = camA;
	self.camB = camB;
	self.desk = desk;
	self.vehicleA = vehicleA;
	self.vehicleB = vehicleB;
	self.camAKeyScroller = camAKeyScroller;
	self.camBKeyScroller = camBKeyScroller;
	self.camAFree = false;
	self.camBFree = false;
	self.isFullscreen = false;

	-- Setup screen and cameras
	self:setVideoMode(conf.screenWidth, conf.screenHeight, false, false, 0);
end

--------------------------------------------------------------------------------
-- Renders one frame
--------------------------------------------------------------------------------
function DuelApp:draw()
	local love_graphics = love.graphics;
	local love_graphics_printf = love_graphics.printf;
	local screenW, screenH = love_graphics.getWidth(), love_graphics.getHeight();
	self.camA:draw();
	self.camB:draw();
	love_graphics.setLineWidth(2);
	-- self.camA:drawOutline();
	-- self.camB:drawOutline();
	love_graphics.setLineWidth(1);
	self.desk:draw();

	--[[ DEBUG: Visualize points
	do
		-- -- Save env
		local r, g, b = love_graphics.getColor();
		local lineW = love_graphics.getLineWidth();
		-- -- Tank gun peg
		-- Peg map pos
		local pegMX, pegMY, pegMZ = self.vehicleA:getRootGrob():getPegPosition(1)
		-- Peg screen pos
		local pegSX, pegSY = self.camA:computeScreenPos(pegMX, pegMY, pegMZ);
		-- Render peg
		love_graphics.setColor(0, 0, 255);
		love_graphics.setLineWidth(2);
		love_graphics.setLineStyle('smooth');
		love_graphics.line(pegSX - 10, pegSY - 10, pegSX + 10, pegSY + 10);
		love_graphics.line(pegSX - 10, pegSY + 10, pegSX + 10, pegSY - 10);
		-- Render floor
		-- love_graphics.setColor(0, 255, 255);
		-- love_graphics.line(pegSX - 10, pegSY - pegMZ - 10, pegSX + 10, pegSY - pegMZ + 10);

		-- -- Gun pivot
		-- Map pos
		local pivMX, pivMY, pivMZ = self.vehicleA:getTurretGrob():getPegPosition(0);
		-- Screen pis
		local pivSX, pivSY = self.camA:computeScreenPos(pivMX, pivMY, pivMZ);
		-- Render
		love_graphics.setColor(255, 255, 0);
		love_graphics.setLineWidth(1);
		love_graphics.setLineStyle('rough');
		love_graphics.line(pivSX - 10, pivSY - 10, pivSX + 10, pivSY + 10);
		love_graphics.line(pivSX + 10, pivSY - 10, pivSX - 10, pivSY + 10);

		-- -- Restore env
		love_graphics.setColor(r, g, b);
		love_graphics.setLineWidth(lineW);
	end
	--]]

	-- Free camera info
	if self.camAFree then
		love_graphics_printf("[Free camera]", screenW / 4, 5, screenW);
	end
	if self.camBFree then
		love_graphics_printf("[Free camera]", (screenW / 4) * 3, 5, screenW);
	end

	-- Display fps
	love_graphics.printf("FPS: "..love.timer.getFPS(), 10, 5, screenW);
	love_graphics.printf("Duel\n______\n\n\nPress escape to exit.\n\n",
		100, 100, screenW - 100);
end

--------------------------------------------------------------------------------
-- Game constructor
--------------------------------------------------------------------------------
return function(bdCore, gameDir)
	return DuelApp:new(bdCore, gameDir);
end

