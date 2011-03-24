--[[

________________________________________________________________________________

                                                                    BD_Undercart
                                                                 Version: Beta 1
                              Copyright (C) 2009 Petr Ohlidal <An00biS@email.cz>

_________________________________ License ______________________________________

This software is provided 'as-is', without any express or implied warranty.
In no event will the authors be held liable for any damages arising from the use
of this software.

Permission is granted to anyone to use this software for any purpose, including
commercial applications, and to alter it and redistribute it freely, subject to
the following restrictions:

1. The origin of this software must not be misrepresented; you must not
	claim that you wrote the original software. If you use this software
	in a product, an acknowledgment in the product documentation would be
	appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
	misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

_______________________________ Description ____________________________________

Provides an universal implementations of vehicles for 2d games.

Module
	+ newTrackedUndercart( grob:Table(UndercartGrobCompatible) ) : Table(TrackedUndercart)

-- This interface shows methods which are needed in a graphical representation
Interface UndercartGrobCompatible:
	-- Returns the turret's position in the game world in pixels.
	+ getPosition() : Number, Number
	-- Change the angle (in radians).
	+ rotateRadians() : Nil
	-- Gets the angle of graphic.
	+ getAngleRadians() : Number
	-- Get the angle of the current sprite
	+ getVisualAngleRadians() : Number

Class TrackedUndercart
Attributes:
Methods:
	+ keyPressed( k ) : Nil
	+ keyReleased( k ) : Nil
	+ update(elapsed) : Nil
	+ getSmoothSteering() : Boolean
	+ setSmoothSteering( smoothSteering:Boolean ) : Nil
	+ getSpeed() : Number

--]]

--[[ Example spec:
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
--]]
--------------------------------- Utilities ------------------------------------

-- Check if a table matches the GrobCompatible interface
local function checkUndercartGrobCompatible(t)
	return
		type(t) == "table" and
		type(t.getPosition) == "function" and
		type(t.rotateRadians) == "function" and
		type(t.getAngleRadians) == "function" and
		type(t.getVisualAngleRadians) == "function";

end

local PUBLIC = {};

------------------------------- Tracked Vehicle --------------------------------

local TrackedUndercart = {};
TrackedUndercart.__index = TrackedUndercart;

function PUBLIC.newTrackedUndercart(
		grob,
		maxForwardSpeed, maxReverseSpeed,
		forwardAcceleration, reverseAcceleration,
		forwardSlowdown, reverseSlowdown,
		forwardBrake, reverseBrake,
		goForwardKey, goBackwardKey, goLeftKey, goRightKey,
		rotationSpeed,
		smoothSteering)

	if checkUndercartGrobCompatible(grob)==false then
		error("<BD_Vehicle> newTrackedUndercart: 'grob' argument is invalid."
			.."It must be a table matching the VehicleGrobCompatible interface");
	end
	smoothSteering = smoothSteering==true;

	return setmetatable({
		grob = grob,
		speed = 0,
		rotationSpeed = rotationSpeed,
		maxForwardSpeed = maxForwardSpeed,
		maxReverseSpeed = maxReverseSpeed,
		forwardAcceleration = forwardAcceleration,
		reverseAcceleration = reverseAcceleration,
		forwardSlowdown = forwardSlowdown,
		reverseSlowdown = reverseSlowdown,
		forwardBrake = forwardBrake,
		reverseBrake = reverseBrake,
		goForward = false,
		goBackward = false,
		goLeft = false,
		goRight = false,
		goForwardKey = goForwardKey,
		goBackwardKey = goBackwardKey,
		goLeftKey = goLeftKey,
		goRightKey = goRightKey
	}, TrackedUndercart);
end

function PUBLIC.newTrackedUndercartFromSpec(grob, spec, controls, smoothSteering)
	return PUBLIC.newTrackedUndercart(grob,
		spec.maxForwardSpeed, spec.maxReverseSpeed,
		spec.forwardAcceleration, spec.reverseAcceleration,
		spec.forwardSlowdown, spec.reverseSlowdown,
		spec.forwardBrake, spec.reverseBrake,
		controls.goForwardKey, controls.goBackwardKey, controls.goLeftKey, controls.goRightKey,
		spec.rotationSpeed, smoothSteering);
end

function TrackedUndercart:keyPressed(k)

	if k==self.goForwardKey then
		self.goForward = true;
	elseif k==self.goBackwardKey then
		self.goBackward = true;
	elseif k==self.goLeftKey then
		self.goLeft = true;
	elseif k==self.goRightKey then
		self.goRight = true;
	end
end

function TrackedUndercart:keyReleased(k)
	if k==self.goForwardKey then
		self.goForward = false;
	elseif k==self.goBackwardKey then
		self.goBackward = false;
	elseif k==self.goLeftKey then
		self.goLeft = false;
	elseif k==self.goRightKey then
		self.goRight = false;
	end
end

function TrackedUndercart:update(elapsed)
	---- Updating ----

	-- Update speed
	if self.goForward and not self.goBackward then
		if self.speed>=0 then
			if self.speed<self.maxForwardSpeed then -- Accelerating
				self.speed = self.speed+(self.forwardAcceleration*elapsed)
				if self.speed>self.maxForwardSpeed then
					self.speed=self.maxForwardSpeed
				end
			end
		else -- Braking in reverse movement
			self.speed=self.speed+(self.reverseBrake*elapsed)
		end
	elseif self.goBackward and not self.goForward then
		if self.speed<=0 then
			if self.speed>self.maxReverseSpeed then -- Reverse acceleration
				self.speed = self.speed-(self.reverseAcceleration*elapsed)
				if self.speed<self.maxReverseSpeed then
					self.speed = self.maxReverseSpeed
				end
			end
		else -- Braking
			self.speed = self.speed-(self.forwardBrake*elapsed)
		end
	elseif self.speed~=0 then -- Just slowinself down
		if self.speed>0 then -- Forward movement
			self.speed = self.speed-(self.forwardSlowdown*elapsed)
			if self.speed<0 then
				self.speed = 0
			end
		else -- Reverse movement
			self.speed = self.speed+(self.reverseSlowdown*elapsed)
			if self.speed>0 then
				self.speed = 0
			end
		end
	end

	-- Update angle
	if self.goLeft and not self.goRight then
		local change = (-self.rotationSpeed*elapsed);
		--print("<Update Left> angle change deg:",change);
		self.grob:rotateDegrees(change);
	elseif self.goRight and not self.goLeft then
		local change = self.rotationSpeed*elapsed;
		--print("<Update Right> angle change deg:",change);
		self.grob:rotateDegrees(change);
	end

	-- Update position
	if self.speed~=0 then
		local m = math
		local angleRad = self.smoothSteering
			and self.grob:getAngleRadians()
			or self.grob:getVisualAngleRadians()
		local x,y = self.grob:getPosition()
		local speed = self.speed*elapsed
		local moveX = m.sin(angleRad)*speed
		local moveY = (m.cos(angleRad)*speed)*0.7
		self.grob:setPosition(x+moveX*-1, y+moveY)
	end

end

function TrackedUndercart:getSmoothSteering()
	return self.smoothSteering;
end

function TrackedUndercart:setSmoothSteering(smoothSteering)
	self.smoothSteering = smoothSteering==true;
end

function TrackedUndercart:getSpeed()
	return self.speed;
end

return function (BDT_Undercart_Dir)
	return PUBLIC;
end