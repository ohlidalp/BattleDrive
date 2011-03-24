--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_GUI
--------------------------------------------------------------------------------
--module("BDT_GUI.BDT_GUI_SheetTextContent");

--------------------------------------------------------------------------------
-- @class class
-- @name SheetTextContent
-- @description Renders a text label in the sheet.
-- @field colorR : number Text color component.
-- @field colorG : number Text color component.
-- @field colorB : number Text color component.
-- @field colorA : number Text color component.
-- @field bgColorR : number Background color component.
-- @field bgColorG : number Background color component.
-- @field bgColorB : number Background color component.
-- @field bgColorA : number Background color component.
-- @field sheet : Sheet the Sheet to render.
-- @field offsetX : Number X offset of the text
-- @field offsetY : Number Y offset of the text
-- @field align : string One of LOVE's alignment constants.
--------------------------------------------------------------------------------

local love = love;
local love_graphics = love.graphics;

return function (BDT_GUI)

local SheetTextContent = {
	align = "left";
	colorR = 255,
	colorG = 255,
	colorB = 255,
	colorA = 255,
};
SheetTextContent.__index = SheetTextContent;

--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
function BDT_GUI.newSheetTextContent(text, offsetX, offsetY, font, limit)
	if not font and not love.graphics.getFont() then
		error("ERROR: BDT_GUI.newSheetTextContent(): No font available");
	end
	return setmetatable({
		sheet = false,
		text = text,
		font = font or love.graphics.getFont(),
		offsetX = offsetX or 0,
		offsetY = offsetY or 0,
		limit = limit or 0,
	},SheetTextContent);
end

--------------------------------------------------------------------------------
-- Sets the text color
--------------------------------------------------------------------------------
function SheetTextContent:setColor(r,g,b,a)
	self.colorR = r;
	self.colorG = g;
	self.colorB = b;
	self.colorA = a;
end

--------------------------------------------------------------------------------
-- Sets the text background color
--------------------------------------------------------------------------------
function SheetTextContent:setBgColor(r,g,b,a)
	self.bgColorR = r;
	self.bgColorG = g;
	self.bgColorB = b;
	self.bgColorA = a;
end

function SheetTextContent:attachSheet(s)
	if BDT_GUI.isInstanceOfSheet(s) then
		self.sheet=s;
	else
		error("ERROR: SheetTextContent:attachSheet(): Supplied object ["..tostring(s).."] is not a Sheet");
	end
end

function SheetTextContent:setAlign(a)
	self.align=a;
end

function SheetTextContent:toString()
	return "BDT_GUI.SheetTextContent["..tostring(self.text).."]";
end

--------------------------------------------------------------------------------
-- Replaces the displayed text
-- @param o mixed Any object - function uses tostring() to get the value.
--------------------------------------------------------------------------------
function SheetTextContent:setText(o)
	self.text = tostring(o);
end

function SheetTextContent:draw()
	--[[ #DBG#
		print("SheetTextContent '"..self.text.."':draw()");
	--]]
	local love_graphics = love.graphics;
	local love_graphics_setFont = love_graphics.setFont;
	local love_graphics_setColor = love_graphics.setColor;
	-- Setup environment (and save the global)
	local envR,envG,envB,envA = love_graphics.getColor();
	local envFont = love_graphics.getFont();
	love_graphics_setFont(self.font);
	love_graphics_setColor(self.colorR,self.colorG,self.colorB,self.colorA);

	-- Draw text
	local sheet = self.sheet;
	local sheetPos = sheet.absolutePos;
	local centerX = sheetPos.x+self.offsetX;
	local centerY = sheetPos.y+self.offsetY;
	--[[
		print("  SheetTextContent:draw() ["..self.text.."] sheetPos.x:"..tostring(sheetPos.x)
			.." self.offsetX:"..tostring(self.offsetX).." centerX:"..tostring(centerX).." centerY:"..tostring(centerY).." self.limit:"..tostring(self.limit));--]]
	love_graphics.printf(self.text, centerX, centerY, self.limit, self.align);

	-- Restore environment
	love_graphics_setColor(envR,envG,envB,envA);
	love_graphics_setFont(envFont);
end

end -- Enclosing function