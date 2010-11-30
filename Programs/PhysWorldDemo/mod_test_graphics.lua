-- mod test graphics

return function(mod, bd, bdgui, bdx, bdguix)

mod.graphics = {};

do -- closure for explosion-june
	local frameCount = 8;
	local frameDelay = 0.15;
	local explosionImage = love.graphics.newImage("graphics/explosion-june.png");
	
	local AnimGrob = {};
	AnimGrob.__index = self;
	
	function AnimGrob:update(elapsed)
		self.anim:update(elapsed);
		self.duration = self.duration+elapsed;
		if(self.duration>frameCount*frameDelay)then
			self.dead = true;
		end;
	end;
	
	function AnimGrob:getImageArea()
		return 
			self.x+self.imageArea.x,
			self.y+self.imageArea.y,
			self.imageArea.w,
			self.imageArea.h
	end;
	
	function mod.graphics.newExplosionGrob(x,y)
		local g = {};
		g.anim = love.graphics.newAnimation(
			explosionImage, 180, 135, frameDelay, frameCount);
		g.anim:setMode(love.mode_once);
		g.anim:setCenter(-7,6.5);
		g.duration = 0;
		g.dead = false;
		g.x = x;
		g.y = y;
		-- relative to animation's center
		g.imageArea = {
			x=-83,
			y=-74,
			w=180,
			h=93
		};
		g.z = (g.x+g.imageArea.x)+h;
		
		return setmetatable(g,AnimGrob);
	end;
	
	function mod.graphics.newExplosionEntity(x,y)
		local e = mod.graphics.newExplosionGrob(x,y);
		function e:getTowerGrob()
			return self;
		end
		return e;
	end;
end; -- end closure for explosion-june

end; -- enclosing function 