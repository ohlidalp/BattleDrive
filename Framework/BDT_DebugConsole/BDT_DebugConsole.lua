--[[
________________________________________________________________________________
                               BDT_DebugConsole

Created by Petr 'An00biS' Ohlidal
Version: beta 1 test release

A very simple class for fast runtime display of debug info.

Module interface:
	newDebugConsole(
		_font, --Default: Uses the one currently set in LOVE
		absX, absY, -- Initializes 'absolutePos'. Default:10
		_width, _height, -- 0 means no limits
		)

DebugConsole class:
Attributes:
	- stream : String          -- String with the data.
	+ absolutePos : Table{x,y} -- Console's screen position (pixels).
	+ w
	+ h
	- font
Methods:
	+ ff() : Nil               -- Delete all text
	+ lf() : Nil               -- New line
	+ print(...) : Nil         -- Prints arguments
	+ printLn(...) : Nil       -- Prints arguments and jumps to new line
	+ draw() : Nil             -- Displays the console.

________________________________________________________________________________

--]]

local DebugConsole = {};
DebugConsole.__index = DebugConsole;

-- Optimization
local tostring = tostring;
local love_graphics = love.graphics;

local function newDebugConsole( _font,absX, absY, _width, _height )
	---- Defaults ----
	absX = absX or 10;
	absY = absY or 15;
	if _width==0 then _width=nil end
	if _height==0 then _height=nil end
	if not _font then
		_font = love_graphics.getFont();
		if not _font then
			error("<BD_DebugConsole::newDebugConsole> no font available");
		end
	end
	return setmetatable(
	{
		absolutePos = { x=absX, y=absY };
		w = _width;
		h = _height;
		font = _font;
		stream=""
	},
	DebugConsole
	);
end;

function DebugConsole:ff()
	self.stream="";
end;

function DebugConsole:lf()
	self.stream = self.stream.."\n";
end;

function DebugConsole:print(...)
	for index, item in ipairs(arg) do
		self.stream = self.stream..tostring(item)
	end;
end;

function DebugConsole:printLn( ... )
	self:print(...);
	self:lf();
end;

function DebugConsole:draw()
	-- Save enviroment settings
	if self.font then
		local prevFont = love_graphics.getFont();
	end
	if self.x and self.y then
		love_graphics.setScissor( self.absolutePos.x, self.absolutePos.y, self.w, self.h );
	end

	-- Draw the text
	love_graphics.draw(self.stream, self.absolutePos.x, self.absolutePos.y);

	-- Restore enviroment
	if prevFont then
		love_graphics.setFont(prevFont);
	end
	if self.x and self.y then
		love_graphics.setScissor();
	end
end;

return function(BDT_DebugConsole_Dir) -- Enclosing function
	return {newDebugConsole=newDebugConsole};
end