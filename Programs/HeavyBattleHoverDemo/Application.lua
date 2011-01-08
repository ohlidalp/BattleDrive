--[[
________________________________________________________________________________

 Heavy Battle Hover Demo
 Version 1.2
 Copyright (C) 2009-2010 Petr Ohlidal <An00biS@An00biS.cz>

_________________________________ License ______________________________________

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
	claim that you wrote the original software. If you use this software
	in a product, an acknowledgment in the product documentation would be
	appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
	misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

________________________________________________________________________________

--]]

local love = love;
local math = math;
local HBHD_Config = {
	toggleGrassKey               = "g";
	showHelpKey                  = "f1";
	showDebugConsoleKey          = "f2";

	turretTurnLeftKey            = "q";
	turretTurnRightKey           = "e";
	goLeftKey                    = "a";
	goRightKey                   = "d";
	goForwardKey                 = "w";
	goBackwardKey                = "s";
	toggleSmoothSteeringKey      = "i";

	turretTurnLeftKey            = "q";
	turretTurnRightKey           = "e";
	turretToggleDirectControlKey = "t";
	turretTurnSpeedRadians       = math.pi/1.7; -- Radians per second
	blasterTurnSpeedRadians      = math.pi*1.1;
	allGunsToggleSyncRotationKey = "y";
	allGunsRespectHeightKey      = "r";

	blasterR_goRightKey          = "l";
	blasterR_goLeftKey           = "k";
	blasterR_directControlKey    = "p";
	blasterL_goRightKey          = "j";
	blasterL_goLeftKey           = "h";
	blasterL_directControlKey    = "i";
	blasterB_goLeftKey           = "n";
	blasterB_goRightKey          = "m";
	blasterB_directControlKey    = "o";

	resetGunsKey                 = "r";
	bgColor                      = {50,150,80,255};
	enableBlasters               = true;
	helpColor                    = {0,255,255,255}; -- Also debug console.
	helpBgColor                  = {0,0,0,150};
	helpW                        = 400;
	helpH                        = 300;
};
HBHD_Config.vehicleSpec = {
	---- Vehicle properties ----
	speed=0;
	maxForwardSpeed=300, -- Pixels per sec.
	rotationSpeed=80; -- Degrees per sec.
	-- Speed units to add in a secod of time
	forwardAcceleration = 250;
	reverseAcceleration = 188,
	-- Speed units to substract in a second of time
	forwardSlowdown = 50,
	reverseBrake = 133, -- Positive number
	maxReverseSpeed = -178, -- Must be a negative number
	reverseSlowdown = 50,
	forwardBrake = 133,
}

local HBHD_App = {false,false,false,false,false};
HBHD_App.__index = HBHD_App;

--------------------------------------------------------------------------------
-- KeyPressed LOVE callback
--------------------------------------------------------------------------------
function HBHD_App:keyPressed(key,unicode)
	-- Aliases
	local l = love;
	local config = HBHD_Config;
	local bools = self.bools;
	local turretTurntable = self.turretTurntable;
	local blasterRightTurntable = self.blasterRightTurntable;
	local blasterLeftTurntable = self.blasterLeftTurntable;
	local blasterRearTurntable = self.blasterRearTurntable;

	-- toggling
	if key == config.toggleGrassKey then
		bools.drawGrass = not bools.drawGrass;
	elseif key == config.showHelpKey then
		bools.showHelp = not bools.showHelp;
		if bools.showHelp then
			self.desk:attachSheet(self.helpSheet);
		else
			self.desk:removeSheet(self.helpSheet);
		end
	elseif key == config.showDebugConsoleKey then
		bools.showDebugConsole = not bools.showDebugConsole;
		if bools.showDebugConsole then
			self.desk:attachSheet(self.dbgConsoleSheet);
		else
			self.desk:removeSheet(self.dbgConsoleSheet);
		end

	elseif key == config.allGunsToggleSyncRotationKey then
		turretGrob:setSynchronizeVisualAngle( not turretGrob:getSynchronizeVisualAngle() );
		leftBlasterGrob:setSynchronizeVisualAngle( not leftBlasterGrob:getSynchronizeVisualAngle() );
		rightBlasterGrob:setSynchronizeVisualAngle( not rightBlasterGrob:getSynchronizeVisualAngle() );
		rearBlasterGrob:setSynchronizeVisualAngle( not rearBlasterGrob:getSynchronizeVisualAngle() );
	elseif key == config.allGunsRespectHeightKey then
		turretTurntable:setRespectHeight( not turretTurntable:getRespectHeight() );
		blasterRightTurntable:setRespectHeight( not blasterRightTurntable:getRespectHeight() );
		blasterLeftTurntable:setRespectHeight( not blasterLeftTurntable:getRespectHeight() );
		blasterRearTurntable:setRespectHeight( not blasterRearTurntable:getRespectHeight() );

	-- Turrets control toggles
	elseif(key==config.turretToggleDirectControlKey)then
		turretTurntable:setDirectControl( not turretTurntable:getDirectControl() );
	elseif key==config.blasterR_directControlKey then
		blasterRightTurntable:setDirectControl( not blasterRightTurntable:getDirectControl() );
	elseif key==config.blasterL_directControlKey then
		blasterLeftTurntable:setDirectControl( not blasterLeftTurntable:getDirectControl() );
	elseif key==config.blasterB_directControlKey then
		blasterRearTurntable:setDirectControl( not blasterRearTurntable:getDirectControl() );


	elseif key == "escape" then
		print(" ==== Heavy Battle Hover Demo: Exit ==");
		self:exit();
	end;
	self.hoverUndercart:keyPressed(key);
	--print("<main.keypressed> key:"..tostring(key));
	turretTurntable:keyPressed(key);

	blasterRightTurntable:keyPressed(key);
	blasterLeftTurntable:keyPressed(key);
	blasterRearTurntable:keyPressed(key);

end;

function HBHD_App:keyReleased(key)
	-- turret controls
	self.hoverUndercart:keyReleased(key);
	self.turretTurntable:keyReleased(key);
	self.blasterRightTurntable:keyReleased(key);
	self.blasterLeftTurntable:keyReleased(key);
	self.blasterRearTurntable:keyReleased(key);
end;

function HBHD_App:draw()
	-- Optimize
	local bools = self.bools;
	local love_graphics = love.graphics;
	local love_graphics_draw = love_graphics.draw;
	local config = HBHD_Config;
	local love_graphics_print = love_graphics.print;
	local love_graphics_setColor = love_graphics.setColor;
	local bodyGrob = self.hoverBodyGrob;

	-- Get info
	local screenW,screenH = love_graphics.getWidth(), love_graphics.getHeight();--OLD config.video.w, config.video.h;

	-- Draw ground TODO: Use SpriteBatch
	if bools.drawGrass then
		local grass = grass;
		local spriteW, spriteH = grass:getWidth(), grass:getHeight();
		for xi = 0, screenW, spriteW do
			for yi = 0,screenH, spriteH do
			 	love_graphics_draw(grass, xi, yi);
			 end
		end
	end

	-- Debug console
	if bools.showDebugConsole then
		local console = self.dbgConsoleText;
		console:ff();
		local ucart = self.hoverUndercart;
		local body = bodyGrob;
		local bodyX, bodyY, bodyZ = body:getPosition();
		console:printLn(
			"Body pos \n\tX:"..bodyX.."\n\tY:"..bodyY.."\n\tZ:"..bodyZ
			.."\nSpeed: "..ucart:getSpeed()
			.."\nBodyVisAngleDeg: "..body:getVisualAngleDegrees()
			..'\nBodyVisAngleRad: '..body:getVisualAngleRadians()
			.."\nSteering: "..(ucart:getSmoothSteering() and "Smooth" or "In steps")
			.."\nRotation of turret: "..(self.turretGrob:getSynchronizeVisualAngle()
			and "Synchronized" or "Not synchronized"));
		console:printLn( "Turret control: "..(self.turretTurntable:getDirectControl() and "Keyboard" or "Mouse") );
		console:printLn("Rotation sync:"..(self.turretGrob:getSynchronizeVisualAngle() and "Enabled" or "Disabled"));
		console:printLn("Turret control:"..(self.turretTurntable:getDirectControl() and "Keyboard" or "Mouse"));
		console:printLn("Right blaster control:"..(self.blasterRightTurntable:getDirectControl() and "Keyboard" or "Mouse"));
		console:printLn("Left blaster control:"..(self.blasterLeftTurntable:getDirectControl() and "Keyboard" or "Mouse"));
		console:printLn("Rear blaster control:"..(self.blasterRearTurntable:getDirectControl() and "Keyboard" or "Mouse"));
	end

	-- Display fps
	love_graphics_print("FPS: "..love.timer.getFPS(), screenW-100, screenH-20 );

	-- Show shadows
	local shadows = self.shadows;
	for i, grob in pairs(shadows) do
		grob:draw(grob:getPosition());
	end

	-- Show the hover
	bodyGrob:draw(bodyGrob:getPosition());

	-- Render GUI
	self.desk:draw();
end;

function HBHD_App:update(elapsed)
	--print("<HBHD_App.update>");
	self.hoverUndercart:update(elapsed);
	-- Update the turret
	local mouseX, mouseY = love.mouse.getPosition();
	local turretTurntable = self.turretTurntable;
	turretTurntable:aimAt(mouseX, mouseY);
	turretTurntable:update(elapsed);

	local blet = self.blasterLeftTurntable;
	local brit = self.blasterRightTurntable;
	local bret = self.blasterRearTurntable;
	blet:aimAt(mouseX, mouseY);
	brit:aimAt(mouseX, mouseY);
	bret:aimAt(mouseX, mouseY);

	blet:update(elapsed);
	brit:update(elapsed);
	bret:update(elapsed);
end;

--------------------------------------------------------------------------------
-- Handle a LOVE event
-- @param e string event type (love.event.Event enum)
-- @param a mixed event attribute (depends on event type)
-- @param b mixed event attribute (depends on event type)
-- @param c mixed event attribute (depends on event type)
-- @param d mixed event attribute (depends on event type)
--------------------------------------------------------------------------------
function HBHD_App:handleEvent(e,a,b,c,d)
	local handler = self.handlers[e];
	if handler then
		handler(self,a,b,c,d);
	else
		print("WARNING: HeavyBattleHoverDemo Application: unhandled event '"..tostring(e).."' with args: "..tostring(a)..","..tostring(b)..","..tostring(c)..","..tostring(d));
	end
end

--------------------------------------------------------------------------------
-- Tell this game to exit (externally or internally)
--------------------------------------------------------------------------------
function HBHD_App:exit()
	self.menuApp:endGame();
end

--------------------------------------------------------------------------------
-- Terminate and clean up this game.
--------------------------------------------------------------------------------
function HBHD_App:cleanup()

end

HBHD_App.handlers = {
	kp = HBHD_App.keyPressed,
	kr = HBHD_App.keyReleased,
	mp = HBHD_App.mousePressed,
	mr = HBHD_App.mouseReleased
}

function DBG_printChildren(grob)
	BDT_GROB.printGrobChildren(grob);
end
--------------------------------------------------------------------------------
-- Loads the game data
-- @param menuApp BD_MainMenuApp
-- @param gameDir string Path to current game's dir (slash-terminated)
--------------------------------------------------------------------------------
local function newHBHDApp(menuApp,gameDir)


	-- Load libs
	if not BDT_Grob then
		BDT_Grob = BDT:loadLibrary("Grob");
	end
	if not BDT_Turntable then
		BDT_Turntable = BDT:loadLibrary("Turntable");
	end
	if not BDT_Undercart then
		BDT_Undercart = BDT:loadLibrary("Undercart");
	end
	BDT_GUI = BDT:loadLibrary("GUI");
	BDT_Common = BDT:loadLibrary("Common");

	-- Optimization
	local love = love;
	local love_graphics = love.graphics;
	local love_graphics_print = love_graphics.print;
	local love_graphics_setColor = love_graphics.setColor;
	local love_graphics_present = love_graphics.present;
	local love_timer_getTime = love.timer.getTime;
	local config = menuApp:getConfig();
	local gameConfig = HBHD_Config;
	local bdGraphicsDir = config.graphicsDir;

	-- Video vars
	local screenW = love_graphics.getWidth();--OLD config.video.w;
	local screenH = love_graphics.getHeight();--OLD config.video.h;

	-- Loading status display data.
	local doneColor = {20,200,20,255}
	local normColor = {255,255,255,255}
	local labelX = 50;
	local doneX = 300;
	local yPos = 100;
	local yStep = 15;
	local function printLabel(l)
		love_graphics_print(l,labelX,yPos);
		love_graphics_present();
	end
	local lastTime=0;
	local function printOk()
		love_graphics_setColor(doneColor[1],doneColor[2],doneColor[3],doneColor[4]);
		local t = love_timer_getTime()
		love_graphics_print(t-lastTime.." sec",doneX,yPos);
		lastTime=t;
		love_graphics_setColor(normColor[1],normColor[2],normColor[3],normColor[4]);
		yPos=yPos+yStep;
		love_graphics_present();
	end
	lastTime = love_timer_getTime();

	-- Grobs
	printLabel("Loading hover body...");
	local hoverBodyWorkshop = BDT_Grob.newWorkshop(bdGraphicsDir.."/Grobs/HeavyBattleHover_Body_Blue_W200");
	printOk();
	printLabel("Loading hover shadow...");
	local hoverBodyShadowWorkshop = BDT_Grob.newWorkshop(bdGraphicsDir.."/Grobs/ShadowGrob_HeavyBattleHoverBody_w200");
	printOk();
	printLabel("Loading turret...");
	local turretWorkshop = BDT_Grob.newWorkshop(bdGraphicsDir.."/Grobs/HeavyBattleHover_Turret_Blue_W200");
	printOk();
	printLabel("Loading turret shadow..");
	local turretShadowWorkshop = BDT_Grob.newWorkshop(bdGraphicsDir.."/Grobs/ShadowGrob_HeavyBattleHoverTurret_w200");
	printOk();
	printLabel("Loading blaster...");
	local blasterWorkshop = BDT_Grob.newWorkshop(bdGraphicsDir.."/Grobs/MobileBlaster_Blue_W200");
	printOk();
	printLabel("Loading blaster shadow...");
	local blasterShadowWorkshop = BDT_Grob.newWorkshop(bdGraphicsDir.."/Grobs/ShadowGrob_MobileBlasterTurret_w200");
	printOk();
	printLabel("Building vehicle...");

	-- Hover
	local bodyGrob = hoverBodyWorkshop:buildRoot(screenW/2, screenH/2, 0);
	local bodyShadowGrob = hoverBodyShadowWorkshop:buildSub();
	bodyGrob:attachChild(bodyShadowGrob, 0, -1);
	local turretGrob = turretWorkshop:buildSub();
	bodyGrob:attachChild(turretGrob, 1);
	local turretShadowGrob = turretShadowWorkshop:buildSub();
	turretGrob:attachChild(turretShadowGrob, 0, -1);
	local x,y,h = turretGrob:getMountedPegPosition();

	local rightBlasterGrob = blasterWorkshop:buildSub();
	turretGrob:attachChild(rightBlasterGrob, "Peg_BlasterRight");
	local leftBlasterGrob = blasterWorkshop:buildSub();
	turretGrob:attachChild(leftBlasterGrob, "Peg_BlasterLeft");
	local rearBlasterGrob = blasterWorkshop:buildSub();
	turretGrob:attachChild(rearBlasterGrob, "Peg_BlasterRear");
	local rightBlasterShadowGrob = blasterShadowWorkshop:buildSub();
	rightBlasterGrob:attachChild(rightBlasterShadowGrob, 0, -1);
	local leftBlasterShadowGrob = blasterShadowWorkshop:buildSub();
	leftBlasterGrob:attachChild(leftBlasterShadowGrob, 0, -1);
	local rearBlasterShadowGrob = blasterShadowWorkshop:buildSub();
	rearBlasterGrob:attachChild(rearBlasterShadowGrob, 0, -1);

	-- Turntables
	local turretTurntable = BDT_Turntable.newTurntable(
		turretGrob, HBHD_Config.turretTurnSpeedRadians,
		HBHD_Config.turretTurnLeftKey, HBHD_Config.turretTurnRightKey );
	turretTurntable:setDirectControl(true);

	local blasterRightTurntable = BDT_Turntable.newTurntable(
		rightBlasterGrob, HBHD_Config.blasterTurnSpeedRadians,
		HBHD_Config.blasterR_goLeftKey, HBHD_Config.blasterR_goRightKey);
	local blasterLeftTurntable = BDT_Turntable.newTurntable(
		leftBlasterGrob, HBHD_Config.blasterTurnSpeedRadians,
		HBHD_Config.blasterL_goLeftKey, HBHD_Config.blasterL_goRightKey);
	local blasterRearTurntable = BDT_Turntable.newTurntable(
		rearBlasterGrob, HBHD_Config.blasterTurnSpeedRadians,
		HBHD_Config.blasterB_goLeftKey, HBHD_Config.blasterB_goRightKey);

	blasterRightTurntable:setDirectControl(true);
	blasterLeftTurntable:setDirectControl(true);
	blasterRearTurntable:setDirectControl(true);

	-- Hover Undercart
	local spec = HBHD_Config.vehicleSpec;
	local keys = HBHD_Config;
	local hoverUndercart = BDT_Undercart.newTrackedUndercart(
		bodyGrob,
		spec.maxForwardSpeed, spec.maxReverseSpeed,
		spec.forwardAcceleration, spec.reverseAcceleration,
		spec.forwardSlowdown, spec.reverseSlowdown,
		spec.forwardBrake, spec.reverseBrake,
		keys.goForwardKey, keys.goBackwardKey, keys.goLeftKey, keys.goRightKey,
		spec.rotationSpeed);
	printOk();

	-- Fonts
	local menuFonts = menuApp:getFonts();
	local font = menuFonts.default12 or love_graphics.newFont(12);
	love_graphics.setFont(font);

	-- Other graphics --
	printLabel("Loading grass...");
	local grassPath = bdGraphicsDir.."/Grass_500x350.png";
	grass = love_graphics.newImage(grassPath, love.image_pad_and_optimize);
	printOk();

	local bgColor = HBHD_Config.bgColor;
	love_graphics.setBackgroundColor(bgColor[1],bgColor[2],bgColor[3],bgColor[4]);

	-- GUI
	local desk = BDT_GUI.newDesk();
	-- Debug console
	local sheet = desk:newSheet(0,0,400,300);
	desk:removeSheet(sheet);
	local rend = BDT_GUI.newSheetRenderer(sheet);
	rend:getPalette():setColor("inactiveFill",gameConfig.helpBgColor);
	sheet:setActive(false); -- Also updates colors.
	local textArea = BDT_GUI.newSheetTextArea("Hello debug console!");
	rend:addContent(textArea);
	textArea:setColor(gameConfig.helpColor);
	-- Help
	local helpSheet = desk:newSheet(screenW - gameConfig.helpW, 0, gameConfig.helpW, gameConfig.helpH);
	desk:removeSheet(helpSheet);
	local helpRen = BDT_GUI.newSheetRenderer(helpSheet);
	helpRen:getPalette():setColor("inactiveFill",gameConfig.helpBgColor);
	local helpText = BDT_GUI.newSheetTextArea(
		"W,S : Accelerate/brake\n"..
		"A,D : Turn left/turn right\n"..
		"Q,E : Rotate cannon left/right (if mouse aiming inactive)\n"..
		"L,K : Rotate right blaster\n"..
		"J,H : Rotate left blaster\n"..
		"M,N : Rotate rear blaster\n"..
		--"I : Toggle smooth steering/fixed step steering\n"..
		"G : Toggle grass display\n"..
		"F2 : Display info console\n"..
		"U : Toggle turret keyboard/mouse aiming\n"..
		"P : Toggle right blaster keyboard/mouse aiming\n"..
		"I : Toggle left blaster keyboard/mouse aiming\n"..
		"O : Toggle rear blaster keyboard/mouse aiming\n"..
		"Y : Toggle rotation sync between grobs.\n"..
		"ESC: Exit");
	helpRen:addContent(helpText);
	helpSheet:setActive(false); -- Updates colors
	helpText:setColor(gameConfig.helpColor);

	return setmetatable({
		menuApp = menuApp;
		-- Gui
		desk = desk;
		dbgConsoleSheet = sheet;
		dbgConsoleText = textArea;
		helpSheet = helpSheet;

		rightBlasterGrob = rightBlasterGrob;
		leftBlasterGrob = leftBlasterGrob;
		rearBlasterGrob = rearBlasterGrob;
		turretTurntable = turretTurntable;
		blasterRightTurntable = blasterRightTurntable;
		blasterLeftTurntable = blasterLeftTurntable;
		blasterRearTurntable = blasterRearTurntable;
		hoverUndercart = hoverUndercart;
		hoverBodyGrob = bodyGrob;
		turretGrob = turretGrob;
		-- Shadow grobs
		shadows = {
			blasterRearShadowGrob,
			blasterRightShadowGrob,
			blasterLeftShadowGrob,
			bodyShadowGrob,
			turretShadowGrob
		};
		-- Booleans and toggle keys
		bools = {
			drawGrass = false;
			showHelp = false;
			showDebugConsole = false;
		};
	},HBHD_App);
end;

return newHBHDApp;
