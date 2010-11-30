--[[
________________________________________________________________________________

                                                                    BD_Turntable
                                                                 Version: Beta 1
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

________________________________ Description ___________________________________



Module:
	+ newTurntable(grob, turnSpeed, goRightKey, goLeftKey)


--
Interface TurntableGrobCompatible:
	-- Returns the turret's position in the game world in pixels.
	+ getPosition() : Number, Number, Number
	-- Change the angle of turret's graphical representation (in radians).
	+ rotateRadians() : Nil
	-- Gets the angle of graphic.
	+ getAngleRadians() : Number
	-- Get the angle of the current sprite
	+ getVisualAngleRadians() : Number

Class Turntable:
Attributes:
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
Methods:
	+ aimAt(x,y) : Nil
	-- Sets the grob. Only accepts a table.
	+ setGrob(grob) : Nil
	-- Gets the grob
	+ getGrob() : Table(GrobCompatible)
	+ isAimed() : Boolean
	-- Stops the rotation process.
	+ stop() : Nil
	+ setDirectControl( directControl:Boolean ): Nil
	+ getDirectControl() : Boolean
________________________________________________________________________________

--]]

--------------------------------------------------------------------------------
-- @class table
-- @name BDT_Turntable module interface
-- @description This module provides an universal implementation of a rotating plattform; The class rotates a graphical entity to reach a given angle or aim at given coordinates; It's made to be used with grob as a graphical entity, but will work the same with any object which fits the GrobCompatible interface.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- @class table
-- @name interface GrobCompatible
-- @description This interface shows methods which are needed in a graphical representation of a turntable.

--- Returns the turret's position in the game world (in pixels).
-- @class function
-- @name GrobCompatible:getPosition
-- @return number X
-- @return number Y
-- @return number H

--- Change the angle of turret's graphical representation (in radians).
-- @class function
-- @name GrobCompatible:rotateRadians
-- @param a Angle to rotate

--------------------------------------------------------------------------------

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

-- ________________________________________________________________
--                           Turntable
-- This class links to a sprite or grob (which represents a cannon)
-- and provides an universal implementation of a turret.

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
end;


--- set the gun's target angle
-- targetX, targetY are the map coordinates (pixels) to shoot at
-- @param direction Negative or positive number to decide the rotation path. 0 uses the shorter path.
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

function Turntable:getGrob()
	return self.grob;
end

function Turntable:setGrob(grob)
	if checkTurntableGrobCompatible(grob)==false then
		error("<BD_Turntable> Turtable:setGrob: argument #1 'grob' is invalid."
			.."It must be a table matching the TurntableGrobCompatible interface");
	end
end

function Turntable:getAngleRadians()
	return self.grob:getAngleRadians();
end

function Turntable:getVisualAngleRadians()
	return self.grob:getVisualAngleRadians();
end

function Turntable:stop()
	self.aimingDirection=0;
	self.targetX, self.targetY = 0,0;
end;

function Turntable:keyPressed(k)
	--[[
	print("<Turtable:keyPressed>\n\tkey:"..tostring(k).." goRight:"..tostring(self.goRightKey)
		.." goLeft:"..tostring(self.goLeftKey));
	--]]
	if self.directControl then
		if k==self.goRightKey then
			self.goRight = true;
		elseif k==self.goLeftKey then
			self.goLeft = true;
		end
	end
end

function Turntable:keyReleased(k)
	if self.directControl then
		if k==self.goLeftKey then
			self.goLeft=false;
		elseif k==self.goRightKey then
			self.goRight=false;
		end
	end
end

function Turntable:setGoRight(r)
	self.goRight = r;
end

function Turntable:setGoLeft(l)
	self.goLeft = l
end

function Turntable:setDirectControl(value)
	self.directControl = value==true;
end

function Turntable:getDirectControl()
	return self.directControl;
end

function Turntable:setRespectHeight(r)
	self.respectHeight = r;
end

function Turntable:getRespectHeight()
	return self.respectHeight;
end


return PUBLIC;

end
