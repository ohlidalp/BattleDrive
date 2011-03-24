--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_GUI
--------------------------------------------------------------------------------
-- module("BDT_GUI.BDT_GUI_SheetContent");

--------------------------------------------------------------------------------
-- @class class
-- @name SheetContent
-- @description Something renderable to display in the sheet
--------------------------------------------------------------------------------
return function (BDT_GUI) -- Enclosing function

local SheetContent = {};
SheetContent.__index = SheetContent;

function SheetContent:draw()

end

function SheetContent:attachSheet(s)

end

function SheetContent:toString()
	return "BDT_GUI.SheetContent";
end

function BDT_GUI.newSheetContent()
	return setmetatable({},SheetContent);
end

function BDT_GUI.isInstanceOfSheetContent(o)
	return BDT.isTableAndHasFunctions(o,"draw","attachSheet");
end

end -- Enclosing function