--[[
________________________________________________________________________________

                                                       Heavy Battle Hover Demo
                                                                   Version 1.1
                       Copyright (C) 2009-2010 Petr Ohlidal <An00biS@email.cz>

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
	bgColor                      = {50,150,80,255};--love.graphics.newColor(50,150, 80);
	enableBlasters               = true;
	helpColor                    = {0,255,255,255};--love.graphics.newColor(0,255,255);
	helpBgColor                  = {100,100,100,150};--love.graphics.newColor(100,100,100, 150);
	helpW                        = 400;
	helpH                        = 350;
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
--[[OBSOLETE
HBHD_Config.video1024 = {
	w = 1024,
	h=768,
	fsaa=0,
	vsync=false,
	fulscreen=true
}
HBHD_Config.video800={
	w=800,
	h=600,
	fsaa=0,
	vsync=false,
	fulscreen=false
}
HBHD_Config.video = HBHD_Config.video800;
--]]

local HBHD_App = {false,false,false,false,false};
HBHD_App.__index = HBHD_App;

--------------------------------------------------------------------------------
-- KeyPressed LOVE callback
--------------------------------------------------------------------------------
function HBHD_App:keyPressed(key,unicode)
	--print("DBG HBHD_App.KeyPressed(): key:"..tostring(key));
	local l = love;
	local config = HBHD_Config;
	local bools = self.bools;
	-- toggling
	if     key == config.toggleGrassKey then
		bools.drawGrass = not bools.drawGrass;
	elseif key == config.showHelpKey then
		bools.showHelp = not bools.showHelp;
	elseif key == config.showDebugConsoleKey then
		bools.showDebugConsole = not bools.showDebugConsole;
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
		print("== Heavy Battle Hover Demo: Exit ==");
		self:exit();
	end;
	hoverUndercart:keyPressed(key);
	--print("<main.keypressed> key:"..tostring(key));
	turretTurntable:keyPressed(key);

	blasterRightTurntable:keyPressed(key);
	blasterLeftTurntable:keyPressed(key);
	blasterRearTurntable:keyPressed(key);

end;

function HBHD_App:keyReleased(key)
	-- turret controls
	hoverUndercart:keyReleased(key);
	turretTurntable:keyReleased(key);
	blasterRightTurntable:keyReleased(key);
	blasterLeftTurntable:keyReleased(key);
	blasterRearTurntable:keyReleased(key);
end;

function HBHD_App:draw()
	-- Optimize
	local bools = self.bools;
	local love_graphics = love.graphics;
	local love_graphics_draw = love_graphics.draw;
	local config = HBHD_Config;
	local love_graphics_print = love_graphics.print;
	local love_graphics_setColor = love_graphics.setColor;

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
	console:printLn("Rotation sync:"..(turretGrob:getSynchronizeVisualAngle() and "Enabled" or "Disabled"));
	console:printLn("Turret control:"..(turretTurntable:getDirectControl() and "Keyboard" or "Mouse"));
	console:printLn("Right blaster control:"..(blasterRightTurntable:getDirectControl() and "Keyboard" or "Mouse"));
	console:printLn("Left blaster control:"..(blasterLeftTurntable:getDirectControl() and "Keyboard" or "Mouse"));
	console:printLn("Rear blaster control:"..(blasterRearTurntable:getDirectControl() and "Keyboard" or "Mouse"));

	--[[
	console:printLn(

		"Speed: "..tankVehicle:getSpeed()
		.."\nVisual angle deg: "..hoverGrob:getVisualAngleDegrees()
		--..'\nVisual angle rad: '..tankGrob:getVisualAngleRadians()
		.."\nSteering: "..(tankVehicle:getSmoothSteering() and "Smooth" or "In steps")
		.."\nRotation of turret: "..(gunGrob:getSynchronizeVisualAngle()
			and "Synchronized" or "Not synchronized"));
	console:printLn( "Turret control: "..(gunTurntable:getDirectControl() and "Keyboard" or "Mouse") );
	--]]
	if bools.showDebugConsole then
		console:draw();
	end
	console:ff();

	--- Displaying help
	if bools.showHelp then
		local helpBgColor = config.helpBgColor
		love_graphics_setColor(helpBgColor); --OLD (helpBgColor[1],helpBgColor[2],helpBgColor[3],helpBgColor[4]);
		love_graphics.rectangle( "fill", screenW-config.helpW, 0,
			config.helpW, config.helpH);
		local helpColor = config.helpColor;
		love_graphics_setColor(helpColor[1],helpColor[2],helpColor[3],helpColor[4]);
		love_graphics_print(
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
			"ESC: Exit", (screenW-config.helpW)+10,15);
	else
		love_graphics_print("F1 = Help", 710,15);
	end

	-- Display fps
	love_graphics_print("FPS: "..love.timer.getFPS(), screenW-100, screenH-20 );
	-- Show shadows
	--[[ == Debug ==
		print("<DBG Drawing shadows> #"..#shadows);--]]
	for i, grob in pairs(shadows) do
		--print("\t DBG drawing ["..tostring(i).."] "..grob.name);
		grob:draw(grob:getPosition());
	end

	-- Show the hover
	hoverGrob:draw(hoverGrob:getPosition());
	--hoverGrob:drawPoints();


end;

function HBHD_App:update(elapsed)
	--print("<HBHD_App.update>");
	hoverUndercart:update(elapsed);
	-- Update the turret
	local mouseX, mouseY = love.mouse.getPosition();
	turretTurntable:aimAt(mouseX, mouseY);
	turretTurntable:update(elapsed);

	blasterLeftTurntable:aimAt(mouseX, mouseY);
	blasterRightTurntable:aimAt(mouseX, mouseY);
	blasterRearTurntable:aimAt(mouseX, mouseY);

	blasterLeftTurntable:update(elapsed);
	blasterRightTurntable:update(elapsed);
	blasterRearTurntable:update(elapsed);

end;
--[[
function DBG_printMembers(g, msg)
	print("<DBG DRAWINGORDER "..g.name.." ["..#g.drawingOrder.."]> "..(msg or ""));
	for i, grob in ipairs(g.drawingOrder) do
		print("\t"..i..": "..grob.name);
	end
end
--]]

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

	print("\n===== HeavyBattleHoverDemo Loading =====");
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
	if not BDT_DebugConsole then
		BDT_DebugConsole = BDT:loadLibrary("DebugConsole");
	end
	BDT_Common = BDT:loadLibrary("Common");

	-- Optimization
	local love = love;
	local love_graphics = love.graphics;
	local config = config;
	local love_graphics_print = love_graphics.print;
	local love_graphics_setColor = love_graphics.setColor;
	local love_graphics_present = love_graphics.present;
	local love_timer_getTime = love.timer.getTime;
	local config = menuApp:getConfig();
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
	turretGrob = turretWorkshop:buildSub();
	bodyGrob:attachChild(turretGrob, 1);
	local turretShadowGrob = turretShadowWorkshop:buildSub();
	turretGrob:attachChild(turretShadowGrob, 0, -1);
	local x,y,h = turretGrob:getMountedPegPosition();

	rightBlasterGrob = blasterWorkshop:buildSub();
	turretGrob:attachChild(rightBlasterGrob, "Peg_BlasterRight");
	leftBlasterGrob = blasterWorkshop:buildSub();
	turretGrob:attachChild(leftBlasterGrob, "Peg_BlasterLeft");
	rearBlasterGrob = blasterWorkshop:buildSub();
	turretGrob:attachChild(rearBlasterGrob, "Peg_BlasterRear");
	local rightBlasterShadowGrob = blasterShadowWorkshop:buildSub();
	rightBlasterGrob:attachChild(rightBlasterShadowGrob, 0, -1);
	local leftBlasterShadowGrob = blasterShadowWorkshop:buildSub();
	leftBlasterGrob:attachChild(leftBlasterShadowGrob, 0, -1);
	local rearBlasterShadowGrob = blasterShadowWorkshop:buildSub();
	rearBlasterGrob:attachChild(rearBlasterShadowGrob, 0, -1);

	-- Turntables
	turretTurntable = BDT_Turntable.newTurntable(
		turretGrob, HBHD_Config.turretTurnSpeedRadians,
		HBHD_Config.turretTurnLeftKey, HBHD_Config.turretTurnRightKey );
	turretTurntable:setDirectControl(true);

	blasterRightTurntable = BDT_Turntable.newTurntable(
		rightBlasterGrob, HBHD_Config.blasterTurnSpeedRadians,
		HBHD_Config.blasterR_goLeftKey, HBHD_Config.blasterR_goRightKey);
	blasterLeftTurntable = BDT_Turntable.newTurntable(
		leftBlasterGrob, HBHD_Config.blasterTurnSpeedRadians,
		HBHD_Config.blasterL_goLeftKey, HBHD_Config.blasterL_goRightKey);
	blasterRearTurntable = BDT_Turntable.newTurntable(
		rearBlasterGrob, HBHD_Config.blasterTurnSpeedRadians,
		HBHD_Config.blasterB_goLeftKey, HBHD_Config.blasterB_goRightKey);

	blasterRightTurntable:setDirectControl(true);
	blasterLeftTurntable:setDirectControl(true);
	blasterRearTurntable:setDirectControl(true);


	-- Hover Undercart
	local spec = HBHD_Config.vehicleSpec;
	local keys = HBHD_Config;
	hoverUndercart = BDT_Undercart.newTrackedUndercart(
		bodyGrob,
		spec.maxForwardSpeed, spec.maxReverseSpeed,
		spec.forwardAcceleration, spec.reverseAcceleration,
		spec.forwardSlowdown, spec.reverseSlowdown,
		spec.forwardBrake, spec.reverseBrake,
		keys.goForwardKey, keys.goBackwardKey, keys.goLeftKey, keys.goRightKey,
		spec.rotationSpeed);
	printOk();

	-- Fonts
	--printLabel("Loading fonts...")
	local menuFonts = menuApp:getFonts();
	local font = menuFonts.default12 or love_graphics.newFont(12);
	love_graphics.setFont(font);
	font12 = font;
	--local f30 = defFont30 or love_graphics.newFont(30);
	font45 = font--f30;
	--printOk();

	-- Other graphics --
	printLabel("Loading grass...");
	local grassPath = bdGraphicsDir.."/Grass_500x350.png";
	grass = love_graphics.newImage(grassPath, love.image_pad_and_optimize);
	printOk();

	shadows = {blasterRearShadowGrob, blasterRightShadowGrob, blasterLeftShadowGrob,
		bodyShadowGrob, turretShadowGrob};



	-- -- Constants ----
	DEGREES_IN_RADIAN = (180/math.pi);

	-- -- Global console

	console = BDT_DebugConsole.newDebugConsole();



	hoverGrob = bodyGrob;
	local bgColor = HBHD_Config.bgColor;
	love_graphics.setBackgroundColor(bgColor[1],bgColor[2],bgColor[3],bgColor[4]);

	print("===== HeavyBattleHoverDemo Ready =====");
	return setmetatable({
		menuApp = menuApp;
		-- -- Booleans and toggle keys ----
		bools = {
			drawGrass = false;
			showHelp = false;
			showDebugConsole = false;
		};
	},HBHD_App);
end;

return newHBHDApp;

