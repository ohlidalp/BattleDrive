--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package GameEntities
--------------------------------------------------------------------------------

local TheTankEntityFactory = class('TheTankEntityFactory');

--------------------------------------------------------------------------------
-- @class table
-- @name TankSpec
-- @field speed : number Default: 0
-- @field maxForwardSpeed : number Pixels per second
-- @field rotationSpeed : number Degrees per sec
-- @field forwardAcceleration : number Speed units to add in a secod of time
-- @field reverseAcceleration : number Speed units to add in a secod of time
-- @field forwardSlowdown : number
-- @field reverseBrake : number Positive number
-- @field maxReverseSpeed  : number Must be a negative number
-- @field reverseSlowdown  : number
-- @field forwardBrake  : number
-- @field turretTurnSpeedRadians : number Radians/second.
--------------------------------------------------------------------------------
local _tankSpec = {
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
	turretTurnSpeedRadians = 3.5,
}

--------------------------------------------------------------------------------
-- @class table
-- @name TankControls
-- @field goLeftKey : string
-- @field goRightKey : string
-- @field goForwardKey : string
-- @field goBackwardKey : string
-- @field turretTurnLeftKey : string
-- @field turretTurnRightKey : string
--------------------------------------------------------------------------------
local _tankControls = {
	goLeftKey                    = "a";
	goRightKey                   = "d";
	goForwardKey                 = "w";
	goBackwardKey                = "s";
	turretTurnLeftKey            = "q";
	turretTurnRightKey           = "e";
}

--------------------------------------------------------------------------------
-- Create factory instance
-- @param TheTankEntity : TheTankEntity Class
-- @param bdGraphicsDir : string Path to graphics dir
-- @param statusMarker : BDT_Misc.StatusMarker Displays game loading status.
--------------------------------------------------------------------------------
function TheTankEntityFactory:initialize(TheTankEntity, bdGraphicsDir, statusMarker)
	self.TheTankEntity = TheTankEntity;
	self.tankSpec = _tankSpec;
	self.tankControls = _tankControls;
	if not statusMarker then
		statusMarker = {
			reset = function () end,
			printLabel = function () end,
			printTime = function () end,
		}
	end
	statusMarker:reset();
	statusMarker:printLabel("Loading tank body...");
	-- Tank vehicle
	self.tankWorkshop = BDT_Grob.newWorkshop(bdGraphicsDir.."/TheTankRed_Grob_w300", "grob.lua");
	statusMarker:printTime();
	statusMarker:printLabel("Loading tank cannon...");
	self.gunWorkshop = BDT_Grob.newWorkshop(bdGraphicsDir.."/TankCannon_Red_w300", "grob.lua");
	statusMarker:printTime();
end

--------------------------------------------------------------------------------
-- Setup the factory
-- @param tankControls : TankControls Table with key defs, optional.
-- @param tankSpec : TankControls Table with key defs, optional.
--------------------------------------------------------------------------------
function TheTankEntityFactory:setup(tankControls, tankSpec)
	self.tankSpec = self.tankSpec or _tankSpec;
	self.tankControls = self.tankControls or _tankControls;
end

--------------------------------------------------------------------------------
-- Create entity instance.
-- @param posX : number Initial map position
-- @param posY : number Initial map position
-- @param tankControls : TankControls Table with key defs, optional.
-- @param tankSpec : TankControls Table with key defs, optional.
--------------------------------------------------------------------------------
function TheTankEntityFactory:build(posX, posY, tankControls, tankSpec)
	local tankControls = tankControls or self.tankControls;
	local tankSpec = tankSpec or self.tankSpec;
	local tankGrob = self.tankWorkshop:buildRoot(posX, posY, 0);
	local gunGrob = self.gunWorkshop:buildSub();
	tankGrob:attachChild(gunGrob, 1);
	local gunTurntable = BDT_Turntable.newTurntable(
		gunGrob,
		tankSpec.rotationSpeed,
		tankControls.turretTurnLeftKey,
		tankControls.turretTurnRightKey );
	local tankUndercart = BDT_Undercart.newTrackedUndercart(
		tankGrob,
		tankSpec.maxForwardSpeed, tankSpec.maxReverseSpeed,
		tankSpec.forwardAcceleration, tankSpec.reverseAcceleration,
		tankSpec.forwardSlowdown, tankSpec.reverseSlowdown,
		tankSpec.forwardBrake, tankSpec.reverseBrake,
		tankControls.goForwardKey, tankControls.goBackwardKey,
		tankControls.goLeftKey, tankControls.goRightKey,
		tankSpec.rotationSpeed);
	return self.TheTankEntity:new(tankGrob, nil, tankUndercart, gunGrob, gunTurntable);
end

return TheTankEntityFactory;
