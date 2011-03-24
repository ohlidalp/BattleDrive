--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_Map
--------------------------------------------------------------------------------

return function (BDT_GfxCamera)

--- Althernative implementation of love.graphics.SpriteBatch
BDT_GfxCamera.FakeBatch = class("FakeBatch");
local FakeBatch = BDT_GfxCamera.FakeBatch;

function FakeBatch:initialize(image, maxTiles)
	self.maxTiles = maxTiles;
	local list = {};
	local i = 0;
	local ins = table.insert;
	for i = 1, maxTiles do
		ins(list, {nil, nil, nil});
	end
	self.list = list;
	self.idx = 1;
	self.image = image;
end

function FakeBatch:_set(idx, quad, x, y)
	local t = self.list[idx] or {};
	t.quad = quad;
	t.x = x;
	t.y = y;
	self.list[idx] = t;
end

function FakeBatch:clear()
	for i = 1, self.maxTiles do
		self:_set(i, nil, nil, nil);
	end
	self.idx = 1;
end

function FakeBatch:addq(quad, x, y)
	self:_set(self.idx, quad, x, y);
	self.idx = self.idx + 1;
end

function FakeBatch:draw()
	local love_graphics_drawq = love.graphics.drawq;
	local img = self.image;
	-- print(string.format("DBG FakeBatch:draw() self.idx=%s",self.idx));
	for i = 1, self.idx do
		local tile = self.list[i];
		--[[
		print(string.format("DBG\tFakeBatch:draw() img=%s quad=%s",
				tostring(img), tile and tostring(tile.quad) or "TILE==NIL!!"));
		--]]
		if tile and tile.quad then
			love_graphics_drawq(img, tile.quad, tile.x, tile.y);
		end
	end
end

end




