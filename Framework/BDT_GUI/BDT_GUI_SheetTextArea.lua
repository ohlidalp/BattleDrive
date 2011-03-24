--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_GUI
--------------------------------------------------------------------------------
-- module("BDT_GUI.BDT_GUI_SheetTextArea");

--------------------------------------------------------------------------------
-- @class class
-- @name SheetTextArea
-- @description Renders text into sheet.
-- @field stream : string String with the data.
-- @field align : string One of LOVE's alignment constants.
-- @field sheet : Sheet the Sheet to render.
-- @field color : Color Text color; Default = black.
-- @field paddingRight : number Default: 5px
-- @field paddingLeft : number Default: 5px
-- @field paddingTop : number Default: 5px
--------------------------------------------------------------------------------

-- Optimization
local tostring = tostring;
local love_graphics = love.graphics;

-- Locals
local SheetTextArea = {};
SheetTextArea.__index = SheetTextArea;
SheetTextArea.__tostring = function()
	return "BDT_GUI.SheetTextArea";
end

local function DBG_PrintColor(msg, color)
	print("DBG ["..msg.."] color: ",color[1],color[2],color[3],color[4]);
end

--------------------------------------------------------------------------------
-- Create new textarea.
-- @param text string
-- @param font Font Default: Uses the one currently set in LOVE
--------------------------------------------------------------------------------
local function newSheetTextArea(text, font)
	if not font then
		font = love_graphics.getFont();
		if not font then
			error("BDT_SheetTextArea::newSheetTextArea(): No font available");
		end
	end
	return setmetatable(
	{
		color = {0,0,0,255};
		font = font;
		stream = text;
		paddingLeft = 5;
		paddingRight = 5;
		paddingTop = 5;
		align = "left";
	},
		SheetTextArea
	);
end;

--------------------------------------------------------------------------------
-- Sets the text color
-- @param pointer table Internal color attribute
-- @param rOrTable number/table{r,g,b,a} Red component/ table with color.
--------------------------------------------------------------------------------
function SheetTextArea:setColor(rOrTable,g,b,a)
	local c = self.color;
	if type(rOrTable) == "table" then
		self.color = rOrTable;
		if(rOrTable[4] == nil) then
			self.color[4] = c[4];
		end
	else
		c[1] = rOrTable;
		c[2] = g;
		c[3] = b;
		c[4] = a;
	end
end

function SheetTextArea:setPaddings(left, right, top)
	self.paddingLeft = left;
	self.paddingRight = right;
	self.paddingTop = top;
end

function SheetTextArea:setAlign(a)
	self.align = a;
end

--------------------------------------------------------------------------------
-- Delete all text.
--------------------------------------------------------------------------------
function SheetTextArea:ff()
	self.stream = "";
end;

--------------------------------------------------------------------------------
-- New line.
--------------------------------------------------------------------------------
function SheetTextArea:lf()
	self.stream = self.stream.."\n";
end;

--------------------------------------------------------------------------------
-- Add text.
--------------------------------------------------------------------------------
function SheetTextArea:print(...)
	for index, item in ipairs(arg) do
		self.stream = self.stream..tostring(item);
	end
end

--------------------------------------------------------------------------------
-- Add text and new line.
--------------------------------------------------------------------------------
function SheetTextArea:printLn( ... )
	self:print(...);
	self:lf();
end

function SheetTextArea:attachSheet(s)
	if BDT_GUI.isInstanceOfSheet(s) then
		self.sheet = s;
	else
		error("ERROR: SheetTextArea:attachSheet(): Supplied object ["..tostring(s).."] is not a Sheet");
	end
end

function SheetTextArea:draw()
	-- Aliases
	local love_graphics = love.graphics;
	local love_graphics_setFont = love_graphics.setFont;
	local love_graphics_setColor = love_graphics.setColor;

	-- Setup environment (and save the global)
	local envR,envG,envB,envA = love_graphics.getColor();
	local envFont = love_graphics.getFont();
	love_graphics_setFont(self.font);
	love_graphics_setColor(self.color);

	-- Draw text
	local sheet = self.sheet;
	local sheetPos = sheet.absolutePos;
	local sheetX, sheetY = sheetPos.x, sheetPos.y;
	local sheetW, sheetH = self.sheet:getDimensions();
	-- Draw the text
	love_graphics.printf(
		self.stream,
		sheetX + self.paddingLeft,
		sheetY + self.paddingTop,
		sheetX + sheetW - self.paddingRight,
		self.align);

	-- Restore environment
	love_graphics_setColor(envR,envG,envB,envA);
	love_graphics_setFont(envFont);
end

return function(BDT_GUI)
	BDT_GUI.newSheetTextArea = newSheetTextArea
end