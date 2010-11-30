--[[
Battledale graphical camera

== GfxCamera methods ==
	
	+ addTowerGrob( newGrob )
	+ addTowerGrobs( t )
	+ removeTowerGrob(grob)
	+ addShadowGrob(s)
	+ addShadowGrobs(s)
	+ setMapPos( _x, _y )
	+ moveOnMap( moveX, moveY )
	+ getUseCustomRenderers()
	+ setUseCustomRenderers(value)
	+ addCustomRenderer(r)
	+ removeCustomRenderer(r)
	+ getNoTowerGrobs()
	+ getNoVisibleTowerGrobs()
	+ getNoShadowGrobs()
	+ getNoVisibleShadowGrobs()
	+ computeMapPos( screenX, screenY )
	+ draw()
	
	- updateTowerGrobLists()
	- updateShadowGrobLists()
	- grobIsVisible( grob )
	- drawOutline()
	- drawTiles()
	- drawTableOfGrobs(t)
	
== Notes ==
Grob types:
	"Tower grob" is a grob which has to be z-sorted for correct displaying.
	"Shadow grob" is a grob which represents a shadow, and thus is drawn before
		tower grobs and the ordering doesn't matter.
	Technically, they're the same.
	
Grob storage:
	For performance, every GfxCamera object keeps its own lists of grobs 
	instead of reading a global one. There are two lists (one for 
	grobs currently visible and second for other grobs) for every
	grob type, i.e 2 for tower grobs, 2 for shadow grobs.
	Thus, to make a grob display in the camera, you need to distribute
	it using "add*Grob*()" methods.
	
Viewport:
	The viewport must be a bdgui.sheet or object of following model:
	{
		absolutePos = {x, y}, -- Screen's position
		w, -- Width
		h  -- Height
	}
--]]

return function ( battledale ) -- Enclosing function

local GfxCamera = {};
GfxCamera.__index = GfxCamera;

---- Constructor ----

local function newGfxCamera( _map, _mapPosVec, _viewportRect )	
	return setmetatable(
		{
			viewport = _viewportRect;
			map = _map;
			-- Map coordinates of the camera's top left corner (pixels)
			mapPos = _mapPosVec;
			visibleGrobs = {};
			notVisibleGrobs = {};
			shadowGrobsVisible = {};
			shadowGrobsNotVisible = {};
			emptyTable = {};
			useCustomRenderers=true;
			
			-- FIXME obsolete, use objects (renderers) instead
			customDrawingFunctions = battledale.newCallbackList(); 
			
			customRenderers = battledale.newRunnablesList();
		},
		GfxCamera
	);
end;

--- This method moves tower grobs between 'visible' and 'not visible' tables.
-- Note: newly visible grobs are inserted into the 'visible' table
-- according to their z-index.
function GfxCamera:updateTowerGrobLists()
	-- Move newly visible grobs
	for notVisIndex, newGrob in ipairs(self.notVisibleGrobs) do
		if(self:grobIsVisible(newGrob)) then
			table.remove( self.notVisibleGrobs, notVisIndex );
			-- Find the index to insert the new grob	
			local frontZ = -1000;
			local rearZ = 0;
			for visIndex, visGrob in ipairs(self.visibleGrobs) do
				rearZ = frontZ;
				frontZ = visGrob.z;
				if( newGrob.z>=rearZ and newGrob.z<=frontZ ) then	
					table.insert( self.visibleGrobs, visIndex, newGrob );
					newGrob=nil;
					break;
				end;
			end;
			-- If the grob wasn't inserted, put it in the front
			if(newGrob) then
				table.insert(self.visibleGrobs, newGrob);
			end;
		end;
	end;
	
	-- Move grobs which are not visible 
	for visIndex, grob in ipairs(self.visibleGrobs) do
		if( not self:grobIsVisible(grob) ) then
			table.remove( self.visibleGrobs, visIndex );
			table.insert( self.notVisibleGrobs, grob );
		end;
	end;
end;
GfxCamera.updateGrobLists = GfxCamera.updateTowerGrobLists; -- FIXME deprecated name

function GfxCamera:updateShadowGrobLists()
	-- Move newly visible shadows
	for index, shadow in ipairs(self.shadowGrobsNotVisible) do
		if( self:grobIsVisible(shadow) ) then
			table.remove(self.shadowGrobsNotVisible,index);
			table.insert(self.shadowGrobsVisible,shadow);
		end;
	end;
	-- Move hidden shaddows
	for index, shadow in ipairs(self.shadowGrobsVisible) do
		if( not self:grobIsVisible(shadow) ) then
			table.remove(self.shadowGrobsVisible,index);
			table.insert(self.shadowGrobsNotVisible,shadow);
		end;
	end;
end;

function GfxCamera:grobIsVisible( grob )
	local x1,y1,x2,y2 = grob:getImageArea();
	local bx1,by1,bx2,by2 = 
		self.mapPos.x, self.mapPos.y,
		self.mapPos.x+self.viewport.w, self.mapPos.y+self.viewport.h;
	local overlap = battledale.aabbsOverlap(x1,y1,x2,y2,bx1,by1,bx2,by2);
	--[[
	console:printLn("<grobIsVisible>");
	console:printLn("    grob [x1]"
		..x1.." [y1]"..y1.." [x2]"..x2.." [y2]"..y2);
	console:printLn("    viewport [x1]"
		..bx1.." [y1]"..by1.." [x2]"..bx2.." [y2]"..by2);
	console:printLn("    overlap:"..(overlap and "YES" or "no"));
	--]]
	return overlap;
end;

function GfxCamera:addTowerGrob( newGrob )
	--[[
	print("GfxCamera:addTowerGrob() newGrob:\n"..battledale.table.toString(newGrob)
		.."\nvisible:"..tostring(self:grobIsVisible(newGrob)));
	--]]
	if( self:grobIsVisible(newGrob) ) then
		--print("GfxCamera:addTowerGrob() visible");
		-- If there are grobs already, insert it into the right place
		if #self.visibleGrobs>0 then
			-- Find the index to insert the new grob	
			local frontZ = -1000;
			local rearZ = 0;
			for visIndex, visGrob in ipairs(self.visibleGrobs) do
				rearZ = frontZ;
				
				frontZ = visGrob.z;
				if( newGrob.z>=rearZ and newGrob.z<=frontZ ) then	
					
					table.insert( self.visibleGrobs, visIndex, newGrob );
					newGrob=nil;
					break;
				end;
			end;
			if(newGrob)then
				--print("GfxCamera:addTowerGrob() inserted in front (iteration failed)");
				table.insert(self.visibleGrobs, newGrob);
			end;
		else -- Just put it in the front
			--print("GfxCamera:addTowerGrob() inserted in front (no visible grobs)");
			table.insert(self.visibleGrobs, newGrob);
		end;
	else
		--print("GfxCamera:addTowerGrob() inserted as not visible");
		--print("totalGrobs:",self:getNoTowerGrobs()+self:getNoShadowGrobs());
		table.insert( self.notVisibleGrobs, newGrob );
	end;
end;
GfxCamera.addGrob = GfxCamera.addTowerGrob; -- FIXME deprecated name

function GfxCamera:removeTowerGrob(grob)
	local gone = battledale.table.removeByValue( self.visibleGrobs, grob );
	if gone then
		return true;
	end;
	return battledale.table.removeByValue( self.notVisibleGrobs, grob );
end;

function GfxCamera:addShadowGrob(s)
	if(self:grobIsVisible(s))then
		table.insert(self.shadowGrobsVisible,s);
	else
		table.insert(self.shadowGrobsNotVisible,s);
	end;
end;
GfxCamera.addShadow = GfxCamera.addShadowGrob; -- FIXME deprecated name

function GfxCamera:addShadowGrobs(st)
	for i,s in ipairs(st) do
		self:addShadow(s);
	end;
end;
GfxCamera.addShadows = GfxCamera.addShadowGrobs; -- FIXME deprecated name

function GfxCamera:addTowerGrobs( t )
	for index, grob in ipairs(t) do
		self:addGrob(grob);
	end;
end;
GfxCamera.addGrobs = GfxCamera.addTowerGrobs; -- FIXME deprecated name

function GfxCamera:drawOutline()
	love.graphics.rectangle( love.draw_line, self.viewport.absolutePos.x, self.viewport.absolutePos.y,
		self.viewport.w, self.viewport.h );
end;

function GfxCamera:setMapPos( _x, _y )
	self.mapPos.x = _x;
	self.mapPos.y = _y;
end;

function GfxCamera:moveOnMap( moveX, moveY )
	self.mapPos.x = self.mapPos.x + moveX;
	self.mapPos.y = self.mapPos.y + moveY;
end;

function GfxCamera:drawTiles()
	
	-- get viewport's top left corner map position
	local tlCornerMapX = self.mapPos.x;
	local tlCornerMapY = self.mapPos.y;
	
	-- get corner tiles array coordinates (remember lua indices start with 1)
	-- top left tile
	local tlTileX, tlVpOffsetX = math.modf( tlCornerMapX/self.map.constants.tile.w );
	local tlTileY, tlVpOffsetY = math.modf( tlCornerMapY/self.map.constants.tile.h );
	if tlVpOffsetX ~= 0 then 
		tlTileX = tlTileX+1;
		tlVpOffsetX = tlVpOffsetX*self.map.constants.tile.w ;
	end;
	if tlVpOffsetY ~= 0 then 
		tlTileY = tlTileY+1;
		tlVpOffsetY = tlVpOffsetY*self.map.constants.tile.h;
	end;
	
	-- bottom right tile
	local brTileX, brRemX = math.modf( (tlCornerMapX+self.viewport.w)/self.map.constants.tile.w );
	local brTileY, brRemY = math.modf( (tlCornerMapY+self.viewport.h)/self.map.constants.tile.h );
	if brRemX ~= 0 then brTileX = brTileX+1 end;
	if brRemY ~= 0 then brTileY = brTileY+1 end;
	
	-- get screen position of top left tile
	local tileScrOffsetX = self.viewport.absolutePos.x-tlVpOffsetX;
	local tileScrOffsetY = self.viewport.absolutePos.y-tlVpOffsetY;
		
	local tileY, tileX;
	for tileY = tlTileY, brTileY, 1 do
		for tileX = tlTileX, brTileX, 1 do
			local tileGraphic = self.map:getTile( tileX, tileY );
			if(tileGraphic ~= nil) then
				--[[
				console:printLn("tile <"..tostring(self.map:getTileIndex(tileX,tileY)) 
					.."> y:",tileY,"x:",tileX);
				--]]
				--print("<gfxCamera:draw>tileGraphic, tileScrOffsetX, tileScrOffsetY:",tileGraphic, tileScrOffsetX, tileScrOffsetY);
				love.graphics.draw( tileGraphic, tileScrOffsetX, tileScrOffsetY );
			end;
			tileScrOffsetX = tileScrOffsetX+self.map.constants.tile.w;
		end;
		tileScrOffsetX = self.viewport.absolutePos.x-tlVpOffsetX;
		tileScrOffsetY = tileScrOffsetY+self.map.constants.tile.h;
	end;
end;

function GfxCamera:drawTableOfGrobs(t)
	for index, grob in ipairs(t) do
		--[[
		print("camera:drawTableOfGrobs: grob x,y:",grob.pos.x,grob.pos.y,
			" self.mapPos:", self.mapPos.x, self.mapPos.y,
			" viewport.absolutePos: ",self.viewport.absolutePos.x,
				self.viewport.absolutePos.y );
		--]]
		grob:draw(
			(grob.pos.x-self.mapPos.x)+self.viewport.absolutePos.x,
			(grob.pos.y-self.mapPos.y)+self.viewport.absolutePos.y );	
	end;
end;

function GfxCamera:draw()
	local origColor = love.graphics.getColor();
	--[[
	print("gfxCam:draw() self.viewport.absolutePos:"..tostring(self.viewport.absolutePos)..
		" x:"..tostring(self.viewport.absolutePos.x));
	--]]
	love.graphics.setScissor(
			self.viewport.absolutePos.x, self.viewport.absolutePos.y, 
			self.viewport.w, self.viewport.h );
			
	self:updateTowerGrobLists();
	self:updateShadowGrobLists();
	self:drawTiles();
	battledale.grob.zInsertSort(self.visibleGrobs);
	self:drawTableOfGrobs(self.shadowGrobsVisible);
	self:drawTableOfGrobs(self.visibleGrobs);
	self:drawOutline();
	
	-- Run custom drawing functions
	self.customDrawingFunctions:call(self);
	
	-- Run custom renderer objects
	self.customRenderers:run(self);
		
	love.graphics.setScissor();
	love.graphics.setColor(origColor);
end;

-- Computes map coordinates (in pixels) from a screen point
function GfxCamera:computeMapPos( screenX, screenY )
	return 
		(screenX-self.viewport.absolutePos.x)+self.mapPos.x,
		(screenY-self.viewport.absolutePos.y)+self.mapPos.y;
end;

function GfxCamera:getNoVisibleTowerGrobs()
	return #self.visibleGrobs;
end;

function GfxCamera:getNoTowerGrobs()
	return #self.notVisibleGrobs+#self.visibleGrobs;
end;

function GfxCamera:getNoVisibleShadowGrobs()
	return #self.shadowGrobsVisible;
end;

function GfxCamera:getNoShadowGrobs()
	return #self.shadowGrobsVisible+#self.shadowGrobsNotVisible;
end;

function GfxCamera:addCustomRenderer(r)
	self.customRenderers:add(r);
end;

function GfxCamera:removeCustomRenderer(r)
	self.customRenderers:remove(r);
end;

function GfxCamera:setUseCustomRenderers(value)
	self.useCustomRenderers=value;
end;

function GfxCamera:getUseCustomRenderers()
	return self.useCustomRenderers;
end;

return newGfxCamera;

end; -- End of enclosing function
