
return function(mod,bd,bdx)

local TurretAi = {};
TurretAi.__index = TurretAi;

function TurretAi:update(elapsed)
	local gunX, gunY = self.turret:getMapPos();
	--[[
	console:print('TurretAI [Type:"'..tostring(self.turret.type)
		..'" Team:"'..self.turret.team.name
		..'" Pos:'
		..math.modf(gunX)..'x'
		..math.modf(gunY)..']: ');
	--]]
	---- Find a target ----
	-- Check if the turret has target
	if(self.target)then
		local targetX, targetY = self.target:getMapPos();
		-- Check if target moved
		if(targetX~=gunX or targetY~=gunY)then
			-- Aim
			if not self.turret:aimAt(self.target:getMapPos()) then
				-- Target is out of range
				self.target = false;
			end;
		end;
	end;
	if not self.target then
		-- Find new target
		--[[
		console:printLn("finding new target ("..#self.units.." chances)");
		--]]
		for unitIndex, unit in ipairs(self.units) do
			--[[
			console:print("    "..unitIndex.." "..unit.type.." ");
			--]]
			if(unit~=self.turret)then
				if( self.turret:isInRange(unit:getMapPos()) )then
					-- Check if the unit is enemy
					local enemy = false;
					for index, enemyTeam in ipairs(self.turret.team.enemies)do
						if enemyTeam == unit.team then
							enemy=true;
						end;
					end;
					if(enemy)then
						self.target = unit;
						-- Update data and aim the gun
						self.targetMapPos.x, self.targetMapPos.y = self.target:getMapPos();
						self.turret:aimAt(self.target:getMapPos());
						-- [[
						console:printLn("target acquired");
						--]]
						return;
					--else
						--[[
						console:printLn("not enemy ("..unit.team.name..")");
						--]]
					end;

				--else
					--[[
					console:printLn("out of range");
					--]]
				end;
			--else -- if(unit~=self.turret)
				--[[
				console:printLn("turret itself");
				--]]
			end; -- if(unit~=self.turret)
		end; -- for
	end;
	self.turret:update(elapsed);
end;

local AI = {};

function AI.newTurretAI(turret, map, units)
	return setmetatable(
	{
		turret = turret; -- mod_test_bdx turret object.
		units = units;
		map = map;
		target=nil; -- target unit;
		targetMapPos = {
			x=0;
			y=0;
		};
	},
	TurretAi);
end;

--- Draws a line from a turret to its target
function AI.drawTargetingLines(gfxCamera)
	--print("AI.drawTargetingLines gfxCam:",bdx.printTable(gfxCamera));
	-- setup
	local origColor = love.graphics.getColor();
	local origLineWidth = love.graphics.getLineWidth();
	love.graphics.setColor(255,0,0,255);
	love.graphics.setLineWidth(1);

	-- Create grob-table parser function
	local function drawGrobTable(cam,grobTable)
		for index,grob in ipairs(grobTable) do
			-- Check if the grob is an aimed turret
			if( grob.unit
					and grob.unit.ai
					and getmetatable(grob.unit.ai)==TurretAi
					and grob.unit.ai.target ) then
				-- Draw the line
				local targetPos = grob.unit.ai.target:getTowerGrob().pos;
				-- print("AI.drawTargetingLines grob:",bdx.printTable(grob));
				love.graphics.line(
					-- turret X position on the screen
					(grob.pos.x-cam.mapPos.x)+cam.viewport.absolutePos.x,
					-- turret Y position on the screen
					(grob.pos.y-cam.mapPos.y)+cam.viewport.absolutePos.y,
					-- target X position on the screen
					(targetPos.x-cam.mapPos.x)+cam.viewport.absolutePos.x,
					-- target Y position on the screen
					(targetPos.y-cam.mapPos.y)+cam.viewport.absolutePos.y
					);
			end;
		end;
	end;

	-- draw lines
	drawGrobTable(gfxCamera,gfxCamera.visibleGrobs);
	drawGrobTable(gfxCamera,gfxCamera.notVisibleGrobs);

	-- restoration
	love.graphics.setColor(origColor);
	love.graphics.setLineWidth(origLineWidth);
end;

mod.ai = AI;
end;

-- @param watchzoneAABB Bounding box of the area to patrol (x,y,w,h) in map coordinates (pixels).
--        Must also contain 'relative' attribute, telling whether the cooordinates
--        are relative to the turret or absolute.