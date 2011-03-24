--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_GUI
--------------------------------------------------------------------------------
--module("BDT_GUI.BDT_GUI_Palette")

--- @package BDT_GUI

--------------------------------------------------------------------------------
-- @class table
-- @name Palette
-- @description Colors for BDT_GUI's default renderer.
-- @field outlineTopLeft : Color
-- @attr outlineBottomRight : Color
-- @attr fill : Color
-- @attr mouseoverFill : Color
-- @attr mouseoverOutlineTopLeft : Color
-- @attr mouseoverOutlineBottomRight: Color
-- @attr mousedownFill : Color
-- @attr mousedownOutlineTopLeft : Color
-- @attr mousedownOutlineBottomRight : Color
-- @attr inactiveOutline : Color
-- @attr role : string One of ["page"|"label"], where label is a leafSheet.
-- @attr inactiveFill : Color
--------------------------------------------------------------------------------

local function deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

local defFillAlpha = 255;
local downTL = {255,255,255,255};
local downBR = {150,150,150,255};
local downFill = {150,150,200,defFillAlpha};
local lightBlue = { 150,190,255,255 };
local darkBlue = { 50,115,220,255 };
local defPage = {
		fill = {100,100,100,defFillAlpha};
		outlineTopLeft = {150,150,150,255};
		outlineBottomRight = {50,50,50,255};

		mouseoverFill = {130,130,130,defFillAlpha};
		mouseoverOutlineTopLeft = lightBlue;
		mouseoverOutlineBottomRight = darkBlue;

		mousedownFill = {137,156,176,defFillAlpha};
		mousedownOutlineTopLeft = downTL;
		mousedownOutlineBottomRight = darkBlue;

		inactiveFill = {100,100,100,defFillAlpha};
		inactiveOutlineTopLeft = { 150, 150, 155, 255 };
		inactiveOutlineBottomRight = { 50, 50, 55, 255 };

		role = "page";
};

local defLabel = deepcopy(defPage);
defLabel.role = "label";

-- Debug palette
local fillAlpha = 50;
local colorMousedownOutline = { 50,255,50,255 };
local colorMousedownFill = {255,255,0,fillAlpha};
debugPage = {
	shieldedOutline = { 155, 0, 0, 255 }; -- wtf
	shieldedFill = { 155, 0, 0, fillAlpha };
	outline = {100,100,100,255};
	fill = {100,100,100,fillAlpha};
	inactiveOutline = { 0, 0, 155, 255 };
	inactiveFill = {0,0,155,fillAlpha};
	mouseoverFill = {150,150,150,fillAlpha};
	mouseoverOutline = { 150,150,150,255 };
	mousedownFill = {155,155,155,fillAlpha};
	mousedownOutline = colorMousedownOutline;
	role = "page";
};
debugLabel = {
	inactiveOutline = {153,86,57,255};
	inactiveFill = {153,86,57,fillAlpha};
	outline = {255,128,64,255};
	fill = {255,128,64,fillAlpha};
	mouseoverOutline = {255,255,0,255};
	mouseoverFill = colorMousedownFill;
	mousedownOutline = colorMousedownOutline;
	mousedownFill = colorMousedownFill;
	role = "label";
};

local Palette = {};
Palette.__index = Palette;
Palette.__tostring = function()
	return "BDT_GUI.Palette";
end

--------------------------------------------------------------------------------
-- Set color.
-- @param r_t number/table Red or table with color.
-- @param g number
-- @param b number
-- @param a number
--------------------------------------------------------------------------------
function Palette:setColor(name,r_t,g,b,a)
	local col = self[name];
	if not col then
		print("WARNING: BDT_GUI.Palette:setColor(): Color '"..tostring(name).."' doesn't exist");
	elseif type(r_t) == "table" then
		col[1] = r_t[1] or col[1];
		col[2] = r_t[2] or col[2];
		col[3] = r_t[3] or col[3];
		col[4] = r_t[4] or col[4];
	else
		col[1] = r or col[1];
		col[2] = g or col[2];
		col[3] = b or col[3];
		col[4] = a or col[4];
	end
end

--------------------------------------------------------------------------------
-- @class function
-- @name BDT_GUI.newPalette
-- @description Create new palette.
-- @param role string Type of rendered sheet {"page","label" (Default)}
-- @param source string Name of internal palette to copy {"debug","default"}
--------------------------------------------------------------------------------
local function newPalette(role,source)
	local pal;
	if source == "debug" then
		pal = (role == "page") and debugPage or debugLabel;
	else
		pal = (role == "page") and defPage or defLabel;
	end
	local newPal = deepcopy(pal);
	return setmetatable(newPal, Palette);
end

return function( BDT_GUI ) -- enclosing function
	BDT_GUI.newPalette = newPalette;
end