--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_Turntable
-- @description This module provides an universal implementation of a rotating plattform; The class rotates a graphical entity to reach a given angle or aim at given coordinates; It's made to be used with grob as a graphical entity, but will work the same with any object which fits the GrobCompatible interface.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- @class class
-- @name GrobCompatible
-- @description This interface shows methods which are needed in a graphical representation of a turntable.

--- Returns the turret's position in the game world (in pixels).
-- @class function
-- @name GrobCompatible:getPosition
-- @return : number X
-- @return : number Y
-- @return : number H

--- Change the angle of turret's graphical representation (in radians).
-- @class function
-- @name GrobCompatible:rotateRadians
-- @param a Angle to rotate

--- Gets the angle of attached object.
-- @class function
-- @name GrobCompatible:getAngleRadians
-- @return : number Angle in radians

--- Get the angle of the current sprite
-- @class function
-- @name GrobCompatible:getVisualAngleRadians
-- @return : number Angle in radians

--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- @class class
-- @name Turntable
-- @description A rotating plattform.
--------------------------------------------------------------------------------

--[[
Attributes: (INTERNAL - do NOT reference!)
	- turnSpeed : Number -- Rotation speed in radians per second
	-- Direction to rotate. 1 means positive, -1 means negative.
	-- 0 means the gun is aimed and no rotation is required.
	- aimingDirection : Number
	-- Target coordinates
	- targetX : Number
	- targetY : Number
	- targetAngle : Number
	-- The grob to display the gun. The library is designed to work with
	-- grobs, but you can use any table implementing the needed methods.
	- grob : Table(GrobCompatible)
	- lastPositionX : Number
	- lastPositionY : Number
	-- Turntable control toggle. True means the class responds to
	--	keyboard input, false means only "aimAt" method controls the aiming.
	- directControl : Boolean
	-- The angle difference between target angle and current angle.
	-- Always a positive number.
	- radiansLeftToRotate
--]]

--______________________________________________________________________________
--                                Utilities

-- Optimization
local math = math;
local sqrt = math.sqrt;
local abs = math.abs;
local pow = math.pow;
local math_pi = math.pi;
local math_atan2 = math.atan2;

-- Check if a table matches the GrobCompatible interface
local function checkTurntableGrobCompatible(t)
	return
		type(t) == "table" and
		type(t.getPosition) == "function" and
		type(t.rotateRadians) == "function" and
		type(t.getAngleRadians) == "function" and
		type(t.getVisualAngleRadians) == "function"
end

return function(BDT_Turntable_Dir, BDT) -- Enclosing function

local BDT_Common = BDT:loadLibrary("Common");
local getAngle = BDT_Common.getSystemAngle;

local DEGREES_IN_RADIAN = (180/math_pi);
local _2PI = 2*math_pi;

local PUBLIC = {};

--------------------------------------------------------------------------------
--                           Turntable
-- This class links to a sprite or grob (which represents a cannon)
-- and provides an universal implementation of a turret.
--------------------------------------------------------------------------------
local Turntable = {};
Turntable.__index = Turntable;

function Turntable:isAimed()
	return self.aimingDirection==0;
end

--OLD @param range The range object. If number is given, the CircleRange object will be used
--------------------------------------------------------------------------------
-- Creates new Turntable.
-- @param grob The grob to serve as gun; Note: this class doesn't provide methods to update it's position - it must be manipulated externally.
-- @param turnSpeed Radians per second.
--------------------------------------------------------------------------------
function PUBLIC.newTurntable(grob, turnSpeed, goRightKey, goLeftKey)
	local errMsg = "BDT_Turntable.newTurntable()";
	if checkTurntableGrobCompatible(grob)==false then
		error(errMsg.." 'grob' argument is invalid."
			.."It must be a table matching the TurntableGrobCompatible interface");
	end
	if not turnSpeed or turnSpeed==0 then
		error(errMsg.." 'turnSpeed' argument is invalid ("..tostring(turnSpeed).."). "
			.."It must be a nonzero number");
	end
	local grobX, grobY = grob:getPosition();
	return setmetatable(
		{
			turnSpeed = math.abs(turnSpeed),
			grob = grob,
			targetAngle = 0,
			radiansLeftToRotate = 0;
			targetX = grobX,
			targetY = grobY,
			aimingDirection = 0,
			directControl = false,
			goRight = false,
			goRightKey = goRightKey,
			goLeftKey = goLeftKey,
			goLeft = false,
			lastPosX,
			lastPosY,
			respectHeight = true;
		},
			Turntable
		);
end

--------------------------------------------------------------------------------
-- Enables/disables keyboard control
-- @param value : boolean
--------------------------------------------------------------------------------
function Turntable:enableKeyboardControl(value)
	self.directControl = value;
end

--------------------------------------------------------------------------------
-- Tells if keyboard control is active
-- @return : boolean True if keyboard control is active
--------------------------------------------------------------------------------
function Turntable:isKeyboardControlEnabled()
	return self.directControl
end

--------------------------------------------------------------------------------
-- set the gun's target angle
-- @param targetX : number Map coordinates (pixels) to shoot at
-- @param targetY : number Map coordinates (pixels) to shoot at
-- @param direction : number Negative or positive number to decide the rotation path. 0 uses the shorter path.
--------------------------------------------------------------------------------
function Turntable:aimAt(targetX, targetY, direction)
	if not self.directControl then
		local gunX, gunY, gunH = self.grob:getPosition();
		if self.respectHeight then
			targetY = targetY-gunH;
		else
			gunY = gunY-gunH;
			gunH=0;
			targetH=0;
		end
		if
		gunX~=self.lastPosX or gunY~=self.lastPosY
		or targetX~=self.targetX or targetY~=self.targetY
		then
			-- Set new target coords and angle
			self.targetX = targetX;
			self.targetY = targetY;
			self.lastPosX = gunX;
			self.lastPosY = gunY;
			local oldAngle = self.grob:getAngleRadians();
			local newAngle = getAngle(targetX-gunX, targetY-gunY);
			self.targetAngle = newAngle;

			-- Measure angle differences to find the best direction of rotation
			local angleDiffPositiveRotation, angleDiffNegativeRotation;
			if newAngle>oldAngle then
				angleDiffPositiveRotation = newAngle-oldAngle;
				angleDiffNegativeRotation = _2PI-angleDiffPositiveRotation;
			else
				angleDiffNegativeRotation = oldAngle-newAngle;
				angleDiffPositiveRotation = _2PI-angleDiffNegativeRotation;
			end

			-- Decide the direction
			if not direction or direction==0 then
				if angleDiffPositiveRotation<angleDiffNegativeRotation then
					self.aimingDirection = 1;
					self.radiansLeftToRotate = angleDiffPositiveRotation;
				else
					self.aimingDirection = -1;
					self.radiansLeftToRotate = angleDiffNegativeRotation;
				end
			else
				self.aimingDirection = direction;
				if direction>0 then
					self.radiansLeftToRotate = angleDiffPositiveRotation;
				else
					self.radiansLeftToRotate = angleDiffNegativeRotation;
				end
			end
			--[[
			print(string.format("<Turntable:aimAt>\n"
				.."\tgunXY: %.2f %.2f \n"
				.."\ttargetX: %.2f (relative: %.2f) "
				.."targetY: %.2f (relative: %.2f) \n"
				.."\tangleDiffNeg: %.4f "
				.."angleDiffPos: %.4f "
				.."aimingDirection: "..(self.aimingDirection>0 and "Positive" or "Negative").."\n"
				.."\toldAngle: %.2f (%.2f PI), targetAngle: %.2f (%.2f PI)"

				,gunX, gunY, targetX, targetX-gunX, targetY, targetY-gunY,
				angleDiffNegativeRotation, angleDiffPositiveRotation,
				oldAngle, oldAngle/math_pi, self.targetAngle, self.targetAngle/math_pi
				));
			--]]
		end
	end
end;

--------------------------------------------------------------------------------
-- @param elapsed : number Delta time in seconds
--------------------------------------------------------------------------------
function Turntable:update(elapsed)
	--[[
	console:printLn(string.format(
		"<Turntable:update> turretAngle: %0.2f, targetAngle: %0.2f, targetX: %0.2f, targetY: %0.2f",
		self.grob:getAngleRadians(),self.targetAngle, self.targetX, self.targetY));
	--]]
	if not self.directControl then
		if self.aimingDirection ~= 0 then
			local toRotateNow = self.turnSpeed*elapsed;
			if (self.radiansLeftToRotate - toRotateNow)<0 then
				toRotateNow = self.radiansLeftToRotate;
				self.aimingDirection = 0;
				self.radiansLeftToRotate = 0;
			else
				self.radiansLeftToRotate = self.radiansLeftToRotate - toRotateNow;
			end
			self.grob:rotateRadians(toRotateNow*self.aimingDirection);
		end
	else
		if self.goLeft and not self.goRight then
			self.grob:rotateRadians(self.turnSpeed*elapsed);
		elseif self.goRight and not self.goLeft then
			self.grob:rotateRadians(self.turnSpeed*elapsed*-1);
		end
	end;
end;

--------------------------------------------------------------------------------
-- @return : GrobCompatible
--------------------------------------------------------------------------------
function Turntable:getGrob()
	return self.grob;
end

--------------------------------------------------------------------------------
-- @param grob : GrobCompatible
--------------------------------------------------------------------------------
function Turntable:setGrob(grob)
	if checkTurntableGrobCompatible(grob)==false then
		error("<BD_Turntable> Turtable:setGrob: argument #1 'grob' is invalid."
			.."It must be a table matching the TurntableGrobCompatible interface");
	end
end

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
function Turntable:getAngleRadians()
	return self.grob:getAngleRadians();
end

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
function Turntable:getVisualAngleRadians()
	return self.grob:getVisualAngleRadians();
end

--------------------------------------------------------------------------------
-- Stops the rotation process.
--------------------------------------------------------------------------------
function Turntable:stop()
	self.aimingDirection=0;
	self.targetX, self.targetY = 0,0;
end

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
function Turntable:keyPressed(k)
	if self.directControl then
		if k == self.goRightKey then
			self.goRight = true;
		elseif k == self.goLeftKey then
			self.goLeft = true;
		end
	end
	--[ [ DEBUG
	print(string.format("DBG Turtable:keyPressed()\n" ..
			"\tkeyControlActive: %s, key:%s, goRightKey:%s, goLeftKey:%s, goRight:%s, goLeft:%s",
			tostring(self.directControl), k, self.goRightKey, self.goLeftKey,
			tostring(self.goRight), tostring(self.goLeft)));
	--]]
end

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
function Turntable:keyReleased(k)
	if self.directControl then
		if k==self.goLeftKey then
			self.goLeft=false;
		elseif k==self.goRightKey then
			self.goRight=false;
		end
	end
end

--------------------------------------------------------------------------------
-- Start turning turret right
-- @param r : boolean Movement toggle.
--------------------------------------------------------------------------------
function Turntable:setGoRight(r)
	self.goRight = r;
end

--------------------------------------------------------------------------------
-- Start turning turret left
-- @param l : boolean Movement toggle.
--------------------------------------------------------------------------------
function Turntable:setGoLeft(l)
	self.goLeft = l
end

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
function Turntable:setRespectHeight(r)
	self.respectHeight = r;
end

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
function Turntable:getRespectHeight()
	return self.respectHeight;
end


return PUBLIC;

end
