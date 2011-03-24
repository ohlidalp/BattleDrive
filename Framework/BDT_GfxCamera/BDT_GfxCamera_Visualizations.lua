--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_GfxCamera
--------------------------------------------------------------------------------

--- Some extra rendering functions for the GfxCamera
-- module('BDT_GfxCamera.BDT_GfxCamera_Visualizations.lua')

return function(BDT_GfxCamera)

--------------------------------------------------------------------------------
-- @class class
-- @name HPBarsRenderer
-- @description Renders hitpoint bars for units.
--------------------------------------------------------------------------------
local HPBarsRenderer = {};
HPBarsRenderer.__index = self;

--------------------------------------------------------------------------------
function HPBarsRenderer:drawGrob(grob)
	if(grob.hp and grob.maxHp)then
		local perc = grob.hp/grob.maxHp;
		local x,y,w,h = grob:getShade();
		y=y+h+8;
		love.graphics.setColor(hpBarBg);
		love.graphics.rectangle(love.draw_fill, x, y, w, 6 );
		if(perc>0.5)then
			love.graphics.setColor(hpBarGreen);
		elseif(perc>0.25)then
			love.graphics.setColor(hpBarOrange);
		else
			love.graphics.setColor(hpBarRed);
	end
		love.graphics.rectangle(love.draw_fill, x+1,y+1,w-1,h-1);
	end
end

--------------------------------------------------------------------------------
function HPBarsRenderer:draw(camera)
	for index, grob in ipairs(camera.visibleGrobs)do
		self:drawGrob(grob);
	end
end

--------------------------------------------------------------------------------
function BDT_GfxCamera.newHPBarsRenderer()
	local renderer = {};
	renderer.hpBarRed = love.graphics.newColor(255,0,0);
	renderer.hpBarOrange = love.graphics.newColor(255,255,0);
	renderer.hpBarGreen = love.graphics.newColor(0,255,0);
	renderer.hpBarBg = love.graphics.newColor(0,0,0);

	return setmetatable(renderer,HPBarsRenderer);
end

--------------------------------------------------------------------------------
-- @class class
-- @name ShadesRenderer
-- @description Draws 'shades' of grobs - area where grobs 'touch the ground'
--------------------------------------------------------------------------------
local ShadesRenderer = {}
ShadesRenderer.__index = ShadesRenderer;

--------------------------------------------------------------------------------
function BDT_GfxCamera.newShadesRenderer()
	return setmetatable({
		shadeColor = love.graphics.newColor(0,0,255);
	}, ShadesRenderer);
end

--------------------------------------------------------------------------------
function ShadesRenderer:draw(camera)
	love.graphics.setColor(shadeColor);
	for index, grob in ipairs(camera.visibleGrobs)do
		local x,y,w,h = grob:getShade();
		love.graphics.rectangle(
			love.draw_line,
			(x-self.mapPos.x+self.viewport.absolutePos.x),
			(y-self.mapPos.y+self.viewport.absolutePos.y),
			w,h);
	end
end

end -- Package