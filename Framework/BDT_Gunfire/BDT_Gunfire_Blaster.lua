--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_Gunfire
--------------------------------------------------------------------------------
-- module("BDT_Gunfire.BDT_Gunfire_Blaster");

--------------------------------------------------------------------------------
-- @class class
-- @name Projectile
-- @description Turret AI.
--------------------------------------------------------------------------------
-- mod test laser
-- mod method
-- laser projectile

--- NOT FUNCTIONAL YET

local STATE_GETTING_OUT = 1; -- not fully visible yet
local STATE_FLYING = 2;
local STATE_CRASHED = 3; -- crashed but still visible

return function(BDT_Gunfire)

-- set world collision callback
mod.world.setCallback( function(dataA, dataB, contact)
	if(dataA.isProjectile not dataB.isProjectile)then
		if(dataA.isProjectile)then
			dataA:explode();
			if(dataB:takeDamage)then
				dataB:takeDamage(dataA.damage);
			end;
		else
			dataB:explode();
			if(dataA:takeDamage)then
				dataA:takeDamage(dataB.damage);
			end;
		end;
	end;
end );

local Projectile = {};
Projectile.__index = self;

local beamDefaultColor = love.graphics.newColor(255,0,0);

--------------------------------------------------------------------------------
-- @param elapsed : number Delta time in seconds
--------------------------------------------------------------------------------
function Projectile:explode()
	self.exploded = true;
	self.x,self.y = mod.converter:b2MetersToPixels(self.sensBody:getPosition());
	self.beamShortenStepX, self.beamShortenStepY =
		mod.converter:b2MetersToPixels(self.sensBody:getVelocity());
	self.sensBody:destroy();
	self.sensBody = nil;
	self.sensShape = nil;

	self.flame = mod:newFireEffectGrob(self.x,self.y,-1);
	mod:distributeTowerGrob(self.flame);
end;


--------------------------------------------------------------------------------
-- returns a new laser projectile object
--------------------------------------------------------------------------------
function mod:newLaserShot(x,y,angle)
	-- create object
	local projectile = {};
	-- create sensor shape for it
	projectile.sensBody = love.physics.newBody( self.world, x, y );
	projectile.sensShape = love.physics.newCircleShape(
			sensBody, mod.converter:pixelsToB2Meters(2) );
	sensShape:setData( {
		projectile=projectile,
		isProjectile=true
	} );
	projectile.dead = false;
	projectile.launchForce = 1;
	projectile.launchAngle = angle;
	projectile.fromX, projectile.fromY = x,y;
	projectile.x, projectile.y = x,y;
	projectile.beamLocalEndX, projectile.beamLocalEndY = x,y;
	projectile.damage = 55;

	projectile.state = STATE_GETTING_OUT;

	-- handle drawing --
	projectile.beamTargetLength = 150;
	projectile.beamWidth = 2;
	projectile.beamColor = beamDefaultColor;

	function projectile:draw()
		love.graphics.setColor(self.beamColor);
		love.graphics.setLine(self.beamWidth,love.line_smooth);
		love.graphics.line(
			self.x,self.y,
			self.x+self.beamLocalEndX,
			self.y+self.beamLocalEndY);
	end;

	function projectile:getImageArea()
		return
			self.beamLocalEndX<0 and self.x+self.beamLocalEndX or self.x,
			self.beamLocalEndY<0 and self.y+self.beamLocalEndY or self.y,
			math.abs(self.beamLocalEndX),
			math.abs(self.beamLocalEndY);
	end;

	function projectile:update(elapsed)

			-- if the beam is not fully visible yet
			if(self.state==STATE_GETTING_OUT)then
				-- update position
				self.x, self.y = mod.converter.b2MetersToPixels(self.sensBody.getPosition());
				-- expand it
				local x = self.x-self.fromX;
				local y = self.y-self.fromY;
				self.beamLocalEndX = x;
				self.beamLocalEndY = y;
				-- check if it is visible now
				if(bd.vectorLength(x,y,self.launchAngle) >= self.beamTargetLength )then
					self.fullyVisible = true;
				end;
			elseif(self.state==STATE_EXPLODED)then
				-- shorten the beam
				local beamDeadCheck = self.beamLocalEndX > 0;
				self.beamLocalEndX = self.beamLocalEndX + self.beamShortenStepX;
				self.beamLocalEndY = self.beamLocalEndY + self.beamShortenStepY;
				-- if the beam has disappeared, mark this projectile as dead
				if( self.beamLocalEndX>0 ~= beamDeadCheck )then
					self.dead = true;
					self.flame:stop();
				end;
			else
				self.x, self.y = mod.converter.b2MetersToPixels(self.sensBody.getPosition());
			end;
		end;
	end;
end;

--------------------------------------------------------------------------------
-- returns a new laser projectile object
--------------------------------------------------------------------------------
function mod:newFireEffectGrob(x,y,time)
	local grob = {};
	grob.x, grob.y = x,y;
	grob.z = y+3;
	grob.imageArea = {
		y = (0.3*150+10)*-1;
		x = -20;
		w = 40;
		h = (0.3*150+20)*-1;
	};

	function grob:getImageArea()
		return
			self.x+self.imageArea.x,
			self.y+self.imageArea.y,
			self.imageArea.w,
			self.imageArea.h
	end;

	function grob:update(elapsed)
		self.p:update(elapsed);
		if(( not self.p:isActive() ) and self.p:isEmpty())then
			self.dead = true;
		end;
	end;

	function stop()
		self.p:stop();
	end;

	-- create flame particle system
	p = love.graphics.newParticleSystem(mod.laserFlameSprite,400);
	p:setSpeed(150);
	p:setEmissionRate(100);
	p:setLifetime(time);
	p:setParticleLife(0.1,0.3);
	p:setDirection(-90);
	p:setRadialAcceleration(30);
	p:setSpread(15);
	p:setRotation(1,359);
	grob.p = p;

end;

end; -- Enclosing function