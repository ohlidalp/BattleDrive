
return function (BDT_GUI) -- Enclosing function

--------------------------------------------------------------------------------
-- @class table
-- @name class SheetRenderer
-- @description Basic sheet renderer.
-- @field contents table Table of SheetContent objects.
-- @field palette table Table with colors.
-- @field lineColorTL table{r,g,b,a} Outline color for top and left border.
-- @field lineColorBR table{r,g,b,a} Outline color for bottom and right border.
--------------------------------------------------------------------------------
local SheetRenderer = {};
SheetRenderer.__index = SheetRenderer;

--------------------------------------------------------------------------------
-- Creates a new SheetRenderer
-- @param aSheet Sheet Sheet to attach this renderer to. Can be nil.
--------------------------------------------------------------------------------
function BDT_GUI.newSheetRenderer(aSheet)
	if aSheet ~= nil and not BDT_GUI.isInstanceOfSheet(aSheet) then
		error("ERROR: BDT_GUI.newSheetRenderer(): Invalid argument #1 'aSheet', expected nil or Sheet, got ["..tostring(aSheet).."]");
	end
	local palette;
	if aSheet:hasChildren() then
		palette = BDT_GUI.defaultPalette.page;
	else
		palette = BDT_GUI.defaultPalette.label;
	end
	local R = setmetatable({
		fillColor = false;
		lineColor = false;
		palette = palette;
		sheet = aSheet;
		contents = {};
	},SheetRenderer);
	if aSheet~=nil then
		aSheet:attachRenderer(R);
	end
	return R;
end

--------------------------------------------------------------------------------
-- Informs the renderer about mouse activity.
-- @param mouseOver boolean Flags if mouse is over the sheet.
-- @param mouseDown boolean Flats if mouse button is pressed above the sheet.
--------------------------------------------------------------------------------
function SheetRenderer:mouseEvent(mouseOver, mouseDown)
	local pal = self.palette;
	if( mouseOver==true ) then
		if( mouseDown==true ) then
			self.fillColor = pal.mousedownFill;
			self.lineColorTL = pal.mousedownOutlineTopLeft;
			self.lineColorBR = pal.mousedownOutlineBottomRight;
		else
			self.fillColor = pal.mouseoverFill;
			self.lineColorTL = pal.mouseoverOutlineTopLeft;
			self.lineColorBR = pal.mouseoverOutlineBottomRight;
		end;
	else
		self.fillColor = pal.fill;
		self.lineColorTL = pal.outlineTopLeft;
		self.lineColorBR = pal.outlineBottomRight;
	end;
end

--------------------------------------------------------------------------------
-- Informs the renderer that the sheet has been (de)activated.
-- @param v boolean Activity value
--------------------------------------------------------------------------------
function SheetRenderer:sheetActivationEvent(v)
	local pal = self.palette;
	if v==true then
		self.fillColor = pal.fill;
		self.lineColorTL = pal.outlineTopLeft;
		self.lineColorBR = pal.outlineBottomRight;
	else
		self.fillColor = pal.inactiveFill;
		self.lineColorTL = pal.inactiveOutlineTopLeft;
		self.lineColorBR = pal.inactiveOutlineBottomRight;
	end
end

function SheetRenderer:draw()
	-- Optim.
	local love_graphics = love.graphics;
	local love_graphics_line = love_graphics.line;
	local love_graphics_setColor = love_graphics.setColor;
	-- Save env.
	local envR, envG, envB = love_graphics.getColor();
	-- Render the sheet
	love_graphics.setLineStyle( 'rough' );
	--local fill = self.fillColor;
	love_graphics_setColor(self.fillColor)--(fill[1],fill[2],fill[3],fill[4]);
	local sheet = self.sheet;
	local tlX,tlY,trX,trY,brX,brY,blX,blY = sheet:getCorners();--(offsetX, offsetY);
	love_graphics.polygon( 'fill', tlX,tlY,trX,trY,brX,brY,blX,blY);--self.sheet:getCorners(offsetX, offsetY) );
	--local lineColor = self.lineColor;

	love_graphics_setColor(self.lineColorBR);--(lineColor[1],lineColor[2],lineColor[3],lineColor[4]);

	--love.graphics.polygon( 'line',self.sheet:getCorners(offsetX, offsetY) );
	love_graphics_line(blX,blY,brX,brY,trX,trY);
	love_graphics_setColor(self.lineColorTL);
	love_graphics_line(blX,blY,tlX,tlY,trX,trY);
	-- Render contents
	local i;
	local contents = self.contents;
	for i=1,#contents,1 do
		contents[i]:draw();
	end
	-- Restore env.
	love_graphics_setColor(envR, envG, envB);
end

function SheetRenderer:attachSheet(s)
	if BDT_GUI.isInstanceOfSheet(s) then
		self.sheet=s;
		local palette = s:hasChildren() and BDT_GUI.defaultPalette.page or BDT_GUI.defaultPalette.label;
		self.fillColor = palette.fill;
		self.lineColorTL = palette.outlineTopLeft;
		self.lineColorBR = palette.outlineBottomRight;
		self.palette = palette;
	else
		print("WARNING: BDT_GUI.SheetRenderer:attachSheet() Supplied object ["..tostring(s).."] is not a Sheet");
	end
end

--------------------------------------------------------------------------------
-- Adds a renderable content to this renderer; NOTE: MUST be only used on attached renderers, otherwise it fails.
-- @param c SheetContent
--------------------------------------------------------------------------------
function SheetRenderer:addContent(c)
	if not self.sheet then
		print("ERROR: BDT_GUI.SheetRenderer:addContent(): Can't add content to unattached renderer");
		return
	end
	if BDT_GUI.isInstanceOfSheetContent(c) then
		table.insert(self.contents,c);
		c:attachSheet(self.sheet);
	else
		print("WARNING: BDT_GUI.SheetRenderer:addContent() Supplied object ["..tostring(c).."] is not SheetContent");
	end
end

--------------------------------------------------------------------------------
-- Checks whether the object is a SheetRenderer
-- @return boolean True if the object is SheetRenderer, or false if not.
--------------------------------------------------------------------------------
function BDT_GUI.isInstanceOfSheetRenderer(o)
	return BDT.isTableAndHasFunctions(o,"draw","sheetActivationEvent","mouseEvent");
end

end -- End of enclosing function

-- TRASH

