--------------------------------------------------------------------------------
-- @class table
-- @name Sprite
-- @description A sprite which remembers it's pivot point (center) position.
-- @field x number
-- @field y number
-- @field image LOVE.graphics.Image
--------------------------------------------------------------------------------

local Sprite = {};
Sprite.__index = Sprite;

function Sprite:setCenter(x,y)
	self.x, self.y = x,y;
end

local function newGrobSprite(_image,_x,_y)
	--print("DBG IN newSprite");
	local s = setmetatable({
		image=_image,
		x=_x,
		y=_y},
		Sprite);
	--print("DBG newSprite s:"..tostring(s));
	return s;
end

return function(BDT_Grob_Dir)
	return newGrobSprite;
end