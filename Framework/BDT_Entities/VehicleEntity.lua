--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_Entities
--------------------------------------------------------------------------------

return function (BDT_Entity)

---
BDT_Entity.VehicleEntity = class('VehicleEntity', BDT_Entity.Entity);
local VehicleEntity = BDT_Entity.VehicleEntity;
local superclass = BDT_Entity.Entity; -- Optimization of access
---
function VehicleEntity:initialize(rootGrob, shadowGrob, undercart)
	superclass.initialize(self, rootGrob, shadowGrob);
	self.undercart = undercart;
	--[[
	print("DBG VehicleEntity self");
	for name, value in pairs(self) do
		print(string.format("DBG %s:%s",tostring(name),tostring(value)));
	end--]]
end
---
function VehicleEntity:update(dt)
	-- print("DBG VehicleEntity:update:", dt);
	self.undercart:update(dt);
end
---
function VehicleEntity:keyPressed(key, unicode)
	-- print("DBG VehicleEntity:keyPressed:",key);
	self.undercart:keyPressed(key, unicode);
end
---
function VehicleEntity:keyReleased(key)
	self.undercart:keyReleased(key, unicode);
end
---
function VehicleEntity:mousePressed()
	-- Override me!
end
---
function VehicleEntity:mouseReleased()
	-- Override me!
end

end
