--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package GameEntities
--------------------------------------------------------------------------------

local TheTankEntity = class('TheTankEntity', BDT_Entities.VehicleEntity);
local superclass = BDT_Entities.VehicleEntity; -- Optimization of access

---
function TheTankEntity:initialize(rootGrob, shadowGrob, undercart, tGrob, turntable)
	superclass.initialize(self, rootGrob, shadowGrob, undercart);
	self.turretGrob = tGrob;
	self.turntable = turntable;
	--[[print("DBG TheTankEntity self");
	for name, value in pairs(self) do
		print(string.format("DBG %s:%s",tostring(name),tostring(value)));
	end--]]
end

---
function TheTankEntity:update(dt, mouseMapX, mouseMapY)
	superclass.update(self, dt);
	self.turntable:update(dt);
	if self.turretActive then
		self.turntable:aimAt(mouseMapX, mouseMapY);
	end
end

---
function TheTankEntity:keyPressed(key, unicode)
	superclass.keyPressed(self, key, unicode);
	self.turntable:keyPressed(key, unicode);
end

---
function TheTankEntity:keyReleased(key)
	superclass.keyReleased(self, key);
	self.turntable:keyReleased(key);
end

function TheTankEntity:mousePressed()
	-- Override me!
end

function TheTankEntity:mouseReleased()
	-- Override me!
end

---
function TheTankEntity:getTurntable()
	return self.turntable;
end

---
function TheTankEntity:getTurretGrob()
	return self.turretGrob;
end

return TheTankEntity;
