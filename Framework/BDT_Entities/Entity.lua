--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_Entities
--------------------------------------------------------------------------------

return function (BDT_Entity)

---
BDT_Entity.Entity = class('Entity');
local Entity = BDT_Entity.Entity;
---
function Entity:initialize(rootGrob, shadowGrob)
	self.movingPolys   = {};
	self.movingCircles = {};
	self.staticPolys   = {};
	self.staticCircles = {};
	self.rootGrob = rootGrob;
	self.shadowGrob = shadowGrob;
end
---
function Entity:setRootGrob(g)
	self.rootGrob = g;
end
---
function Entity:getRootGrob()
	return self.rootGrob;
end
---
function Entity:setShadowGrob(sg)
	self.shadowGrob = sg;
end
---
function Entity:getShadowGrob()
	return self.shadowGrob;
end
---
function Entity:getMovingPolys()
	return self.movingPolys;
end
---
function Entity:getMovingCircles()
	return self.movingCircles;
end
---
function Entity:getStaticPolys()
	return self.staticPolys;
end
---
function Entity:getStaticCircles()
	return self.staticCircles;
end
---
function Entity:update(dt)
	-- Override me!
end
---
function Entity:keyPressed(key, unicode)
	-- Override me!
end
---
function Entity:keyReleased(key)
	-- Override me!
end
---
function Entity:mouseMoved(newX, newY, oldX, oldY)
	-- Override me!
end
---
function Entity:mousePressed()
	-- Override me!
end
---
function Entity:mouseReleased()
	-- Override me!
end

end
