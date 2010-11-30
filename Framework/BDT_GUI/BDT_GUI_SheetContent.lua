--------------------------------------------------------------------------------
-- @class table
-- @name class SheetContent
-- @description Something renderable to display in the sheet
--------------------------------------------------------------------------------
return function (BDT_GUI) -- Enclosing function

local SheetContent = {};
SheetContent.__index = SheetContent;

function SheetContent:draw()

end

function SheetContent:attachSheet()

end

function SheetContent:toString()
	return "BDT_GUI.SheetContent";
end

function BDT_GUI.newSheetContent()
	return setmetatable({},SheetContent);
end

function BDT_GUI.isInstanceOfSheetContent(o)
	return BDT.isTableAndHasFunctions(o,"draw");
end

end -- Enclosing function