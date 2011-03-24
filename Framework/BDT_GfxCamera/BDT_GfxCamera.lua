--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_GfxCamera
--[[
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
--------------------------------------------------------------------------------
local BDT_GfxCamera = {}; -- Package
-- module("BDT_GfxCamera.BDT_GfxCamera");

--------------------------------------------------------------------------------
-- @class class
-- @name GfxCamera
-- @description Graphical camera
--------------------------------------------------------------------------------

return function ( packageDir ) -- Enclosing function



local GfxCamera = {};
GfxCamera.__index = GfxCamera;

require (packageDir.."/FakeBatch.lua") (BDT_GfxCamera);

-- Util

local RunnablesList={};
RunnablesList.__index = RunnablesList;

local function newRunnablesList()
	local rl = setmetatable({},RunnablesList);
	rl.list={};
	return rl;
end

function RunnablesList:add(r)
	table.insert(self.list,1,r);
	return self;
end

function RunnablesList:remove(r)
	INTERFACE.table.removeByValue(self.list, r);
end

function RunnablesList:run(...)
	for index, runnable in ipairs(self.list) do
		runnable:run(...);
 end
end

--------------------------------------------------------------------------------
-- Create new instance.
-- @param map : Map BDT_Map.Map object
-- @param mapPosVec : Vector table{x,y} = Initial position of camera's top left corner (pixels)
-- @param viewportRect : Sheet Either a sheet or table{absolutePos{x,y},w,h}
-- @param zSortFunction : function Grob-table sorting function. Optional
--------------------------------------------------------------------------------
function BDT_GfxCamera.newGfxCamera( map, mapPosVec, viewportRect, zSortFunction )
	if not BDT_Grob then
		BDT.checkArg("BDT_GfxCamera::newGfxCamera", "zSortFunction", zSortFunction, "function");
	end
	viewportRect = viewportRect or {w = 0, h = 0, absolutePos = {x = 0, y = 0}};

	local tileW, tileH = map:getTileSize();
	local maxTiles = (viewportRect.w / tileW + 1) * (viewportRect.h / tileH + 1);
	--[[
	local batch = love.graphics.newSpriteBatch(
		map:getImage(),
		maxTiles);
	--]]

	local batch = BDT_GfxCamera.FakeBatch:new(map:getImage(), maxTiles);
	return setmetatable(
		{
			viewport = viewportRect;
			map = map,
			-- Map coordinates of the camera's top left corner (pixels)
			mapPos = mapPosVec;
			visibleGrobs = {};
			notVisibleGrobs = {};
			shadowGrobsVisible = {};
			shadowGrobsNotVisible = {};
			emptyTable = {};
			useCustomRenderers=true;
			customRenderers = newRunnablesList();
			zSortFunction = zSortFunction or BDT_Grob.zInsertSort,
			batch = batch,
		},
		GfxCamera
	);
end

--------------------------------------------------------------------------------
-- Sets the viewport
-- @param x : number Absolute screen position
-- @param y : number Absolute screen position
-- @param w : number Absolute screen size
-- @param h : number Absolute screen size
--------------------------------------------------------------------------------
function GfxCamera:setViewport(x, y, w, h)
	local vp = self.viewport;
	vp.absolutePos.x, vp.absolutePos.y, vp.w, vp.h = x, y, w, h;
end

--- Moves tower grobs between 'visible' and 'not visible' tables.
-- Note: newly visible grobs are inserted into the 'visible' table
-- according to their z-index.
function GfxCamera:updateTowerGrobLists()
	-- Move newly visible grobs
	for notVisIndex, newGrob in ipairs(self.notVisibleGrobs) do
		if(self:_isGrobVisible(newGrob)) then
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
    end
   end
			-- If the grob wasn't inserted, put it in the front
			if(newGrob) then
				table.insert(self.visibleGrobs, newGrob);
   end
  end
 end

	-- Move grobs which are not visible
	for visIndex, grob in ipairs(self.visibleGrobs) do
		if( not self:_isGrobVisible(grob) ) then
			table.remove( self.visibleGrobs, visIndex );
			table.insert( self.notVisibleGrobs, grob );
  end
 end
end
GfxCamera.updateGrobLists = GfxCamera.updateTowerGrobLists; -- FIXME deprecated name

--------------------------------------------------------------------------------
-- Internal
--------------------------------------------------------------------------------
function GfxCamera:updateShadowGrobLists()
	-- Move newly visible shadows
	for index, shadow in ipairs(self.shadowGrobsNotVisible) do
		if( self:_isGrobVisible(shadow) ) then
			table.remove(self.shadowGrobsNotVisible,index);
			table.insert(self.shadowGrobsVisible,shadow);
		end
	end
	-- Move hidden shaddows
	for index, shadow in ipairs(self.shadowGrobsVisible) do
		if( not self:_isGrobVisible(shadow) ) then
			table.remove(self.shadowGrobsVisible,index);
			table.insert(self.shadowGrobsNotVisible,shadow);
		end
	end
end

--------------------------------------------------------------------------------
-- Update
-- @param dt : number Time since last frame in seconds.
--------------------------------------------------------------------------------
function GfxCamera:update(dt)
	self:updateTowerGrobLists();
	self:updateShadowGrobLists();
	self:_updateTileBatch();
end

--------------------------------------------------------------------------------
-- Internal
--------------------------------------------------------------------------------
function GfxCamera:_isGrobVisible( grob )
	local x1, y1, x2, y2 = grob:getImageArea();
	local bx1, by1, bx2, by2 =
		self.mapPos.x, self.mapPos.y,
		self.mapPos.x + self.viewport.w, self.mapPos.y + self.viewport.h;
	return BDT.aabbsOverlap (x1, y1, x2, y2, bx1, by1, bx2, by2);
end

--------------------------------------------------------------------------------
-- Add new grob to display lists.
--------------------------------------------------------------------------------
function GfxCamera:addTowerGrob( newGrob )
	--[[
	print("GfxCamera:addTowerGrob() newGrob:\n"..battledale.table.toString(newGrob)
		.."\nvisible:"..tostring(self:_isGrobVisible(newGrob)));
	--]]
	if( self:_isGrobVisible(newGrob) ) then
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
				end
			end
			if newGrob then
				--print("GfxCamera:addTowerGrob() inserted in front (iteration failed)");
				table.insert(self.visibleGrobs, newGrob);
			end
		else -- Just put it in the front
			--print("GfxCamera:addTowerGrob() inserted in front (no visible grobs)");
			table.insert(self.visibleGrobs, newGrob);
		end
	else
		--print("GfxCamera:addTowerGrob() inserted as not visible");
		--print("totalGrobs:",self:getNoTowerGrobs()+self:getNoShadowGrobs());
		table.insert( self.notVisibleGrobs, newGrob );
	end
end

--------------------------------------------------------------------------------
-- Remove grob from display lists.
--------------------------------------------------------------------------------
function GfxCamera:removeTowerGrob(grob)
	local gone = battledale.table.removeByValue( self.visibleGrobs, grob );
	if gone then
		return true;
 end
	return battledale.table.removeByValue( self.notVisibleGrobs, grob );
end

--------------------------------------------------------------------------------
-- Add new grob to display lists.
--------------------------------------------------------------------------------
function GfxCamera:addShadowGrob(s)
	if(self:_isGrobVisible(s))then
		table.insert(self.shadowGrobsVisible,s);
	else
		table.insert(self.shadowGrobsNotVisible,s);
	end
end

--------------------------------------------------------------------------------
-- Draw viewport rectangle border
--------------------------------------------------------------------------------
function GfxCamera:drawOutline()
	love.graphics.rectangle( "line", self.viewport.absolutePos.x, self.viewport.absolutePos.y,
		self.viewport.w, self.viewport.h );
end

--------------------------------------------------------------------------------
-- Sets map position of camera's center
--------------------------------------------------------------------------------
function GfxCamera:setMapPos( _x, _y )
	self.mapPos.x = _x - self.viewport.w / 2;
	self.mapPos.y = _y - self.viewport.h / 2;
end

--------------------------------------------------------------------------------
-- Sets map position of camera's top right corner
--------------------------------------------------------------------------------
function GfxCamera:setMapOffset( _x, _y )
	self.mapPos.x = _x;
	self.mapPos.y = _y;
end

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
function GfxCamera:moveOnMap( moveX, moveY )
	self.mapPos.x = self.mapPos.x + moveX;
	self.mapPos.y = self.mapPos.y + moveY;
end

--------------------------------------------------------------------------------
-- Internal
--------------------------------------------------------------------------------
function GfxCamera:_drawTileBatch()
	if self.batch.draw then
		self.batch:draw();
	else
		love.graphics.draw(self.batch);
	end
	-- print("DBG sprite batch rendered");
end

--------------------------------------------------------------------------------
-- Internal
--------------------------------------------------------------------------------
function GfxCamera:_updateTileBatch()
	-- print("DBG GfxCamera:_updateTileBatch()");
	local math_modf = math.modf;
	local tlCornerMapX = self.mapPos.x; -- Pixels
	local tlCornerMapY = self.mapPos.y;
	local tileW, tileH = self.map:getTileSize(); -- Pixels
	local xTiles, yTiles = self.viewport.w/tileW, self.viewport.h/tileH;

	-- get corner tiles array coordinates (remember lua indices start with 1)
	-- top left tile
	local tlTileX, tlVpOffsetX = math_modf(tlCornerMapX / tileW);
	local tlTileY, tlVpOffsetY = math_modf(tlCornerMapY / tileH);
	if tlVpOffsetX ~= 0 then
		tlTileX = tlTileX + 1;
		tlVpOffsetX = tlVpOffsetX * tileW;
	end
	if tlVpOffsetY ~= 0 then
		tlTileY = tlTileY + 1;
		tlVpOffsetY = tlVpOffsetY * tileH;
	end

	-- bottom right tile
	local brTileX, brRemX = math_modf( (tlCornerMapX+self.viewport.w) / tileW);
	local brTileY, brRemY = math_modf( (tlCornerMapY+self.viewport.h) / tileH);
	if brRemX ~= 0 then brTileX = brTileX+1 end
	if brRemY ~= 0 then brTileY = brTileY+1 end

	-- get screen position of top left tile
	local tileScrOffsetX = self.viewport.absolutePos.x-tlVpOffsetX;
	local tileScrOffsetY = self.viewport.absolutePos.y-tlVpOffsetY;

	local tileY, tileX;
	local array = self.map:getArray();
	self.batch:clear();
	for tileY = tlTileY, brTileY, 1 do
		for tileX = tlTileX, brTileX, 1 do
			local quad = self.map:getQuad(tileX, tileY);
			if quad then
				--[[
				print("\tquad:%d, screenX:%d, screenY:%d ",
						tostring(quad), tileScrOffsetX, tileScrOffsetY);--]]
				self.batch:addq(quad, tileScrOffsetX, tileScrOffsetY);
			end
			tileScrOffsetX = tileScrOffsetX + tileW;
		end
		tileScrOffsetX = self.viewport.absolutePos.x - tlVpOffsetX;
		tileScrOffsetY = tileScrOffsetY + tileH;
	end
end

--------------------------------------------------------------------------------
-- Internal
-- @param t : table List of grobs
--------------------------------------------------------------------------------
function GfxCamera:_drawTableOfGrobs(t)
	local mapX, mapY = self.mapPos.x, self.mapPos.y;
	local screenX, screenY = self.viewport.absolutePos.x, self.viewport.absolutePos.y;
	for index, grob in ipairs(t) do
		-- print(string.format("DBG GfxCamera:_drawTableOfGrobs() drawing %s", BDT.toString(grob)));
		local x, y = grob:getPositionXY();
		grob:draw((x - mapX) + screenX, (y - mapY) + screenY);
	end
end

--------------------------------------------------------------------------------
-- Internal
--------------------------------------------------------------------------------
function GfxCamera:draw()
	-- print("DBG GfxCamera:draw()");
	local love_graphics = love.graphics;
	local love_graphics_setScissor = love_graphics.setScissor;
	local origColorR, origColorG, origColorB = love_graphics.getColor();
	love_graphics_setScissor(
			self.viewport.absolutePos.x, self.viewport.absolutePos.y,
			self.viewport.w, self.viewport.h );

	self:_drawTileBatch();
	self.zSortFunction(self.visibleGrobs);--OLD BDT_GROB.zInsertSort(self.visibleGrobs);
	self:_drawTableOfGrobs(self.shadowGrobsVisible);
	self:_drawTableOfGrobs(self.visibleGrobs);
	--[[
	-- Run custom renderer objects
	self.customRenderers:run(self);--]]

	love_graphics_setScissor();
	love_graphics.setColor(origColorR, origColorG, origColorB);
end

--------------------------------------------------------------------------------
-- Computes map coordinates (in pixels) from a screen point
--------------------------------------------------------------------------------
function GfxCamera:computeMapPos( screenX, screenY )
	return
		(screenX-self.viewport.absolutePos.x)+self.mapPos.x,
		(screenY-self.viewport.absolutePos.y)+self.mapPos.y;
end

--------------------------------------------------------------------------------
-- Computes screen coordinates (in pixels) from a point on map
-- @param mapX : number
-- @param mapY : number
-- @param mapZ : number Virtual height. Optional, defaults to 0
--------------------------------------------------------------------------------
function GfxCamera:computeScreenPos( mapX, mapY, mapZ )
	mapZ = mapZ or 0;
	return
		(mapX - self.mapPos.x) + self.viewport.absolutePos.x,
		((mapY - mapZ) - self.mapPos.y) + self.viewport.absolutePos.y;
end

---
function GfxCamera:getNoVisibleTowerGrobs()
	return #self.visibleGrobs;
end

---
function GfxCamera:getNoTowerGrobs()
	return #self.notVisibleGrobs+#self.visibleGrobs;
end

---
function GfxCamera:getNoVisibleShadowGrobs()
	return #self.shadowGrobsVisible;
end

---
function GfxCamera:getNoShadowGrobs()
	return #self.shadowGrobsVisible + #self.shadowGrobsNotVisible;
end

---
function GfxCamera:addCustomRenderer(r)
	self.customRenderers:add(r);
end

---
function GfxCamera:removeCustomRenderer(r)
	self.customRenderers:remove(r);
end

---
function GfxCamera:setUseCustomRenderers(value)
	self.useCustomRenderers=value;
end

---
function GfxCamera:getUseCustomRenderers()
	return self.useCustomRenderers;
end

require(packageDir .. "/BDT_GfxCamera_Visualizations.lua") (BDT_GfxCamera)

return BDT_GfxCamera;

end -- End of enclosing function
