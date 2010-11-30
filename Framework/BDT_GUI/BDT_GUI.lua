--[[
________________________________________________________________________________

                                                                         BDT_GUI
                                                                    Version: 0.3
                                                       Compatibility: LOVE 0.6.2
                         Copyright (C) 2008-2010 Petr Ohlidal <An00biS@email.cz>

__________________________________ License _____________________________________

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
	claim that you wrote the original software. If you use this software
	in a product, an acknowledgment in the product documentation would be
	appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
	misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

________________________________ Description ___________________________________

Provides a very basic GUI logic. It's not intended to be a full-feature GUI
toolkit, just to help with creating custom game interfaces.

Architecture:
	The Desk object is the GUI manager and root of widget hierarchy. Only one
	such object is needed. It has to be passed events through callback, plus
	emulating the 'mouseMoved' callbac, which LOVE hasn't, but it's implemented
	for efficiency.

________________________________________________________________________________
--]]

--------------------------------------------------------------------------------
-- @class table
-- @name BDT_GUI module interface
-- @description Provides a very basic GUI logic; It's not intended to be a full-feature GUI toolkit, just to help with creating custom game interfaces.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- @class table
-- @name interface Runnable
-- @description Abstract class implementing some activity.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Executes the implemented activity.
-- @class function
-- @name Runnable:run
-- @param none nil
-- @return nil
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Enclosing function; Needed to pass init params to the module.
-- @param BDT_GUI_Dir string directory where BDT_GUI files reside (without slash)
-- @return BDT_GUI module
--------------------------------------------------------------------------------
return function(BDT_GUI_Dir) -- Enclosing function

--------------------------------------------------------------------------------
-- Check whether a table conforms to the Runnable interface
-- @return Boolean
--------------------------------------------------------------------------------
function isInstanceOfRunnable(t)
	return type(t)=="table" and t.run~=nil and type(t.run)=="function";
end

local BDT_GUI = {};

BDT_GUI.edges = {
	LEFT = false,
	RIGHT = true,
	TOP = false,
	BOTTOM = true
};

--------------------------------------------------------------------------------
-- @class table
-- @name enum events
-- @description Enumeration of event types.
-- @field MOUSEOVER = 1;
-- @field MOUSEOUT = 2;
-- @field MOUSEDOWN = 3;
-- @field MOUSEUP = 4;
-- @field DRAG number When sheet gets resized or moved.
-- @field TREECHANGE number When the sheet hierarchy is changed somewhere.
--------------------------------------------------------------------------------
BDT_GUI.events = {
	MOUSEOVER = 1;
	MOUSEOUT = 2;
	MOUSEDOWN = 3;
	MOUSEUP = 4;
	DRAG = 5;
	TREECHANGE = 6;
}

--- Function checks whether the entered position/rectangle is inside 'self' rectangle
-- self must have these attributes:
-- absolutePos = {x,y}
-- w
-- h
function BDT_GUI.insideRectangle( self, x, y, w, h )
	w = w or 0;
	h = h or 0;
	local is = (x>=self.absolutePos.x and x+w<=self.absolutePos.x+self.w
		and
		y>=self.absolutePos.y and y+h<=self.absolutePos.y+self.h);
	return is;

end;

-- Method for desk and sheet, removes one sheet
function BDT_GUI.removeSheet( self, indexOrPointer )
	--print("<BDT_GUI.removeSheet> indexOrPointer:"..tostring(indexOrPointer));
	if( type(indexOrPointer) == "table" ) then
		for index, sheet in ipairs(self.sheets) do
			if( sheet == indexOrPointer ) then
				table.remove( self.sheets, index );
			end;
		end;
	else
		indexOrPointer = indexOrPointer or #self.sheets;
		table.remove( self.sheets, indexOrPointer );
	end;
end;

function BDT_GUI.removeAllSheets(self)
	local sheets = self.sheets;
	local rm = table.remove;
	while #sheets>0 do
		rm(sheets);
	end
end




BDT_GUI.newColor = newColor;
local fillAlpha = 50;
local function newColor( r,g,b,a )
	return {r,g,b,a}
end
local colorMousedownOutline = newColor( 50,255,50,255 );
local colorMousedownFill = newColor(255,255,0,fillAlpha);

BDT_GUI.debugPalette = {
	page = {
		shieldedOutline = newColor( 155, 0, 0, 255 ); -- wtf
		shieldedFill = newColor( 155, 0, 0, fillAlpha );
		outline = newColor(100,100,100,255);
		fill = newColor(100,100,100,fillAlpha);
		inactiveOutline = newColor( 0, 0, 155, 255 );
		inactiveFill = newColor(0,0,155,fillAlpha);
		mouseoverFill = newColor(150,150,150,fillAlpha);
		mouseoverOutline = newColor( 150,150,150,255 );
		mousedownFill = newColor(155,155,155,fillAlpha);
		mousedownOutline = colorMousedownOutline;
	},
	label = {
		inactiveOutline = newColor(153,86,57,255);
		inactiveFill = newColor(153,86,57,fillAlpha);
		outline = newColor(255,128,64,255);
		fill = newColor(255,128,64,fillAlpha);
		mouseoverOutline = newColor(255,255,0,255);
		mouseoverFill = colorMousedownFill;
		mousedownOutline = colorMousedownOutline;
		mousedownFill = colorMousedownFill;
	}
};
--------------------------------------------------------------------------------
-- @class table
-- @name BDT_GUI.defaultPalette
-- @description Table which Renderer classes use to query colors; This table defines "Palette" object!
--------------------------------------------------------------------------------
local defFillAlpha = 255;
local downTL = {255,255,255,255};
local downBR = {200,200,255,255};
local downFill = {150,150,200,defFillAlpha};
local defPage = {
		outlineTopLeft = {200,200,200,255};
		outlineBottomRight = {100,100,100,255};
		fill = newColor(100,100,100,defFillAlpha);
		mouseoverFill = newColor(100,100,150,defFillAlpha);
		mouseoverOutlineTopLeft = newColor( 150,150,200,255 );
		mouseoverOutlineBottomRight = newColor( 100,100,200,255 );
		mousedownFill = newColor(155,155,200,defFillAlpha);
		mousedownOutlineTopLeft = downTL;
		mousedownOutlineBottomRight = downBR;
		inactiveOutline = newColor( 0, 0, 155, 255 );
		inactiveFill = newColor(0,0,155,defFillAlpha);
};
BDT_GUI.defaultPalette = {
	page = defPage;
	label = defPage;
};
BDT_GUI.newCallbackList = require (BDT_GUI_Dir.."/BDT_GUI_CallbackList.lua");
require (BDT_GUI_Dir.."/BDT_GUI_Arrangement.lua") (BDT_GUI);
require (BDT_GUI_Dir.."/BDT_GUI_Sheet.lua") (BDT_GUI);
require (BDT_GUI_Dir.."/BDT_GUI_SheetRenderer.lua") (BDT_GUI);
require (BDT_GUI_Dir.."/BDT_GUI_SheetContent.lua") (BDT_GUI);
require (BDT_GUI_Dir.."/BDT_GUI_SheetTextContent.lua") (BDT_GUI);
require (BDT_GUI_Dir.."/BDT_GUI_Desk.lua") (BDT_GUI);



return BDT_GUI;
end -- Enclosing function