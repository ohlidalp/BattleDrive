--[[
________________________________________________________________________________

                                                                     Tank Demo
                                                                   Version 1.2
                            Copyright (C) 2009 Petr Ohlidal <An00biS@email.cz>

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
local config = {
	toggleGridKey = love.key_g;
	drawTankKey = love.key_t;
	drawTurretKey = false;
	showHelpKey = love.key_f1;
	showDebugConsoleKey = love.key_f2;
};
config.vehicleSpec = {
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

config.vehicleControls = {
	turretTurnLeftKey=love.key_q;
	turretTurnRightKey=love.key_e;
	goLeftKey = love.key_a;
	goRightKey = love.key_d;
	goForwardKey = love.key_w;
	goBackwardKey = love.key_s,
	toggleSmoothSteeringKey = love.key_i
}

config.tankTurret = {
	goLeftKey = love.key_q,
	goRightKey = love.key_e,
	toggleDirectControlKey = love.key_t,
	turnSpeedRadians = math.pi/1.7; -- Radians per second
	syncRotationKey = love.key_r;
}

local game = {};

function keypressed(key)

	local l = love;
	local config = config;
	local bools = bools;
	-- toggling
	if(key==config.toggleGridKey)then
		bools.drawGrid=not bools.drawGrid;
	elseif(key==love.key_escape)then
		print("== Exit ==");
		love.system.exit();
	elseif(key==config.tankTurret.toggleDirectControlKey)then
		gunTurntable:setDirectControl( not gunTurntable:getDirectControl() );
	elseif(key==config.drawTankKey)then
		bools.drawTank = not bools.drawTank;
	elseif(key==config.drawTurretKey)then
		bools.drawTurret=not bools.drawTurret;
	elseif key==config.vehicleControls.toggleSmoothSteeringKey then
		tankVehicle:setSmoothSteering( not tankVehicle:getSmoothSteering() );
	elseif key==config.showHelpKey then
		bools.showHelp = not bools.showHelp;
	elseif key==config.showDebugConsoleKey then
		bools.showDebugConsole = not bools.showDebugConsole;
	elseif key==config.tankTurret.syncRotationKey then
		gunGrob:setSynchronizeVisualAngle( not gunGrob:getSynchronizeVisualAngle() );
	end;
	tankVehicle:keyPressed(key);
	gunTurntable:keyPressed(key);
end;

function keyreleased(key)
	-- turret controls
	tankVehicle:keyReleased(key);
	gunTurntable:keyReleased(key);
end;

function draw()
	local bools = bools;

	local screenW = 800;
	local screenH = 600;

	if bools.drawGrid then
		local line = love.graphics.line;
		for i=0,screenH,70 do
			line(0,i,screenW,i);
		end;
		for i=0,screenW,100 do
			line(i,0,i,screenH);
		end;
	end

	tankGrob:draw(tankGrob:getPosition());

	-- Debug console
	console:printLn(

		"Speed: "..tankVehicle:getSpeed()
		.."\nVisual angle deg: "..tankGrob:getVisualAngleDegrees()
		--..'\nVisual angle rad: '..tankGrob:getVisualAngleRadians()
		.."\nSteering: "..(tankVehicle:getSmoothSteering() and "Smooth" or "In steps")
		.."\nRotation of turret: "..(gunGrob:getSynchronizeVisualAngle()
			and "Synchronized" or "Not synchronized"));
	console:printLn( "Turret control: "..(gunTurntable:getDirectControl() and "Keyboard" or "Mouse") );
	if bools.showDebugConsole then
		console:draw();
	end
	console:ff();

	--- Displaying help
	if bools.showHelp then
		love.graphics.draw(
			"W,S : Accelerate/brake\n"..
			"A,D : Turn left/turn right\n"..
			"Q,E : Rotate cannon left/right (if mouse aiming inactive)\n"..
			"I : Toggle smooth steering/fixed step steering\n"..
			"G : Toggle grid display\n"..
			"F2 : Display debug console\n"..
			"T : Toggle keyboard/mouse aiming\n"..
			"R : Toggle rotation sync between tank and turret.\n"..
			"ESC: Exit", 410,15);
	else
		love.graphics.draw("F1 = Help", 710,15);
	end

	-- Display fps
	love.graphics.draw("FPS: "..love.timer.getFPS(),screenW-60, screenH-10 );
end;

function update(elapsed)
	-- Update the vehicle
	tankVehicle:update(elapsed);
	-- Update the turret
	gunTurntable:aimAt(love.mouse.getPosition());
	gunTurntable:update(elapsed);
end;

function load()
	-- Optimization
	local love = love;
	local love_graphics = love.graphics;
	local config = config;
	-- Font
	local font = love_graphics.newFont(love.default_font, 12);
	love_graphics.setFont(font);
	-- Libraries
	local BD_Grob = require('BD_Grob.lua');
	local BD_Turntable = require('BD_Turntable.lua');
	local BD_Undercart = require('BD_Undercart.lua');

	-- Tank vehicle creation
	local tankWorkshop = BD_Grob.newWorkshop("TheTankRed_Grob_w300/","grob.lua");
	local gunWorkshop = BD_Grob.newWorkshop("TankCannon_Red_w300/","grob.lua");
	tankGrob = tankWorkshop:buildRoot(400,300);
	gunGrob = gunWorkshop:buildSub();
	tankGrob:attachChild(gunGrob,1);
	gunTurntable = BD_Turntable.newTurntable(
		gunGrob, config.tankTurret.turnSpeedRadians,
		config.tankTurret.goLeftKey, config.tankTurret.goRightKey );
	-- Create the tank vehicle
	local spec = config.vehicleSpec;
	local keys = config.vehicleControls;
	tankVehicle = BD_Undercart.newTrackedUndercart(
		tankGrob,
		spec.maxForwardSpeed, spec.maxReverseSpeed,
		spec.forwardAcceleration, spec.reverseAcceleration,
		spec.forwardSlowdown, spec.reverseSlowdown,
		spec.forwardBrake, spec.reverseBrake,
		keys.goForwardKey, keys.goBackwardKey, keys.goLeftKey, keys.goRightKey,
		spec.rotationSpeed);


	---- Booleans and toggle keys ----
	-- Decides whether the tank steers in steps or smoothly.
	bools = {
		turretActive = false;
		drawGrid=true;
		drawTank=true;
		drawTurret=true;
		showHelp=false;
		showDebugConsole=false;
	}

	---- Constants ----
	DEGREES_IN_RADIAN = (180/math.pi);

	---- Global console
	local DC = require('BD_DebugConsole.lua');
	console = DC.newDebugConsole();

	love.graphics.setColor(150,150,150);
	love.graphics.setColor(255,100,100);
	print("\n=== Grob Tank Demo ====\n");
	love.graphics.setCaption("Tank Demo");
end;
