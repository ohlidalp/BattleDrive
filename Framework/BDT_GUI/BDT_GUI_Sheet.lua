--------------------------------------------------------------------------------
-- @class table
-- @name class Sheet
-- @description Sheet is an universal container; It is movable and scalable, can create hierarchies; Can serve as a window, panel, button, scrollbar, whatever...
-- @field relativePos Table {x,y} - Position relative to parent sheet (in pixels)
-- @field absolutePos Table {x,y} - Sheet's position relative to it's ancestor node; The coordinates are always relative to top left corner, no matter how the sheet is anchored.
-- @field anchor Table { horizontal, vertical } - This sheet's anchors. Defaults: TOP, LEFT
-- @field anchor.horizontal edges.LEFT or edges.RIGHT
-- @field anchor.vertical edges.TOP or edges.BOTTOM
-- @field onMouseOver Table(CallbackList)
-- @field onMouseOut Table(CallbackList)
-- @field onMouseDown Table(CallbackList)
-- @field onMouseUp Table(CallbackList)
-- @field onDrag Table(CallbackList)
-- @field renderer Table(SheetRenderer)
-- @field mouseIsOver Boolean - Flags if mouse is hovering this sheet.
-- @field mouseIsDown Boolean - Flags if mouse is being pressed above this sheet.
-- @field parentChanged Function - Callback which updates this sheet's position and size if parent element was somehow changed.
-- @field name string Sheet name
--------------------------------------------------------------------------------

return function( BDT_GUI ) -- Enclosing function

local Sheet = {};
Sheet.__index = Sheet;
--[[Sheet.__tostring = function()
	return "BDT_GUI.Sheet";
end]]

--------------------------------------------------------------------------------
-- Registers an event handler with this sheet.
-- @param eventType number Item of BDT_GUI.events enum
-- @param handler Either a function or a table with "run" method; When executed, the value gets the sheet as argument.
--------------------------------------------------------------------------------
function Sheet:addEventHandler(eventType,handler)
	local events = BDT_GUI.events;
	if(eventType==events.MOUSEOVER) then
		self.onMouseOver:add(handler);
	elseif(eventType==events.MOUSEOUT) then
		self.onMouseOut:add(handler);
	elseif(eventType==events.MOUSEDOWN) then
		self.onMouseDown:add(handler);
	elseif(eventType==events.MOUSEUP) then
		self.onMouseUp:add(handler);
	elseif(eventType==events.DRAG) then
		self.onDrag:add(handler);
	elseif(eventType==events.TREECHANGE) then
		-- to be implemented
	end
end

--------------------------------------------------------------------------------
-- Unregisters an event handler with this sheet.
-- @param eventType number Item of BDT_GUI.events enum
-- @param handler The handler object/function to remove
-- @return boolean True if the object was removed, false if not found
--------------------------------------------------------------------------------
function Sheet:removeEventHandler(eventType,handler)
	local events = BDT_GUI.events;
	if(eventType==events.MOUSEOVER) then
		return self.onMouseOver:remove(handler);
	elseif(eventType==events.MOUSEOUT) then
		return self.onMouseOut:remove(handler);
	elseif(eventType==events.MOUSEDOWN) then
		return self.onMouseOver:remove(handler);
	elseif(eventType==events.MOUSEUP) then
		return self.onMouseUp:remove(handler);
	elseif(eventType==events.DRAG) then
		return self.onDrag:remove(handler);
	elseif(eventType==events.TREECHANGE) then
		-- to be implemented
	end
end

--------------------------------------------------------------------------------
-- Notifies this sheet that a mouse button was pressed above it.
-- @param x Mouse screen position
-- @param y Mouse screen position
-- @param button The button.
--------------------------------------------------------------------------------
function Sheet:mouseDownEvent(  x, y, button )
	for index, value in ipairs( self.onMouseDown:getList() ) do
		if type(value)=="table" then
		   value:run(self.sheet,x,y,button);
		else
			value( self.sheet, x, y, button );
		end
	end;
	if self.renderer then
		self.renderer:mouseEvent(true,true);
	end
end;

--------------------------------------------------------------------------------
-- Notifies this sheet that a mouse button was released above it.
-- @param x Mouse screen position
-- @param y Mouse screen position
-- @param button The button.
--------------------------------------------------------------------------------
function Sheet:mouseUpEvent(  x, y, button )
	for index, callbackFunction in ipairs( self.onMouseUp:getList() ) do
		callbackFunction( self.sheet, x, y, button );
	end;
	if self.renderer then
		self.renderer:mouseEvent(true,false);
	end
end;

--------------------------------------------------------------------------------
-- Notifies this sheet that a mouse was positioned above it.
--------------------------------------------------------------------------------
function Sheet:mouseOverEvent(  )
	--[[--#DBG#
		print("IN "..self:toString()..":mouseOverEvent()");--]]
	self.mouseIsOver = true;
	if self.renderer then
		self.renderer:mouseEvent(true,false);
	end
	self.onMouseOver:call();
end;

--------------------------------------------------------------------------------
-- Notifies this sheet that a mouse was removed from it.
--------------------------------------------------------------------------------
function Sheet:mouseOutEvent(  )
	self.onMouseOut:call();
	if self.renderer then
		self.renderer:mouseEvent(false,false);
	end
end;

--------------------------------------------------------------------------------
-- Notifies this sheet that it was mouse-dragged.
-- @param mouseNewX Mouse screen position
-- @param mouseNewY Mouse screen position
-- @param mouseOldX Mouse screen position
-- @param mouseOldY Mouse screen position
-- @param buttons table{left,middle,right}
--------------------------------------------------------------------------------
function Sheet:dragEvent(  mouseNewX, mouseNewY, mouseOldX, mouseOldY, buttons )
	for index, callbackFunction in ipairs( self.onDrag:getList() ) do
		callbackFunction( self.sheet, mouseNewX, mouseNewY, mouseOldX, mouseOldY, buttons );
	end;
end;

function Sheet:setName(n)
   self.name=n;
end

-- Constructor
-- Creates new sheet as a child of the current sheet/desk
-- This is a common method for 'sheet' and 'desk' objects.
function BDT_GUI._newSheet( self,
		_relativePosX, _relativePosY, _width, _height,
		_parentChanged, _horizontalAnchor,_verticalAnchor,
		_active )

	local checkArg = BDT.checkArg;
	checkArg("BDT_GUI._newSheet","_relativePosX",_relativePosX,"number")
	checkArg("BDT_GUI._newSheet","_relativePosY",_relativePosY,"number")
	checkArg("BDT_GUI._newSheet","_width",_width,"number")
	checkArg("BDT_GUI._newSheet","_height",_height,"number")

	local sheet = {
		parent = self;
		anchor = {
			horizontal = _horizontalAnchor or BDT_GUI.edges.TOP;
			vertical = _verticalAnchor or BDT_GUI.edges.LEFT;
		};
		relativePos = {
			x = _relativePosX;
			y = _relativePosY;
		};
		absolutePos = {
			x = self.absolutePos.x+_relativePosX;
			y = self.absolutePos.y+_relativePosY;
		};
		w = _width;
		h = _height;
		active = _active or true;
		sheets = {};
	};

	sheet.onMouseOver = BDT_GUI.newCallbackList( sheet );
	sheet.onMouseOut = BDT_GUI.newCallbackList( sheet );
	sheet.onMouseDown = BDT_GUI.newCallbackList( sheet );
	sheet.onMouseUp = BDT_GUI.newCallbackList( sheet );
	sheet.onDrag = BDT_GUI.newCallbackList( sheet );
	sheet.renderer = false;



	sheet.parentChanged =
			type(_parentChanged) == "function"
				and _parentChanged
				or BDT_GUI.arrangement.fixedPosAndScale;
	--print("<newSheet.parentChanged:>", sheet.parentChanged);
	setmetatable( sheet, Sheet );

	table.insert(self.sheets, 1, sheet);

	return sheet;
end;

--------------------------------------------------------------------------------
-- Creates a new Sheet object as a child of this sheet.
-- @name Sheet:newSheet
-- @class function
-- @param _relativePosX Offset from parent element in pixels
-- @param _relativePosY Offset from parent element in pixels
-- @param _width Sheet's witdth in pixels
-- @param _height Sheet's height in pixels
-- @param _parentChanged Function specifying how this sheet will react to moving and resizing of it's parent @see BDT_GUI.Arrange
-- @param _horizontalAnchor A boolean value specifying how this element will be anchored. @see BDT_GUI.edges enum.
-- @param _verticalAnchor A boolean value specifying how this element will be anchored. @see BDT_GUI.edges enum.
-- @return Sheet object
--------------------------------------------------------------------------------
Sheet.newSheet = BDT_GUI._newSheet;

--------------------------------------------------------------------------------
-- Checks whether the supplied rectangle is inside this sheet.
-- @class function
-- @name Sheet:isInside
-- @param x Rectangle's absolute position in pixels
-- @param y Rectangle's absolute position in pixels
-- @param w Rectangle's witdth in pixels
-- @param h Rectangle's height in pixels
Sheet.isInside = BDT_GUI.insideRectangle;

--------------------------------------------------------------------------------
-- Detaches a sheet object from this sheet.
-- @name Sheet:removeSheet
-- @class function
-- @param indexOrPointer A numeric index or a pointer to the sheet which should be removed.
--------------------------------------------------------------------------------
Sheet.removeSheet = BDT_GUI.removeSheet;

--------------------------------------------------------------------------------
-- Detaches all child sheets from this sheet.
-- @name Sheet:removeAllSheets
-- @class function
-- @param none nil
--------------------------------------------------------------------------------
Sheet.removeAllSheets = BDT_GUI.removeAllSheets;

--------------------------------------------------------------------------------
-- A callback for a mouse motion event.
-- LOVE 0.6.x does not contain motion event, only button press event.
-- Maybe it will be added in the future, for now it must be called by the user.
-- @param mouseNewX New mouse coordinate in pixels
-- @param mouseNewY New mouse coordinate in pixels
-- @param mouseOldX Old mouse coordinate in pixels
-- @param mouseOldY Old mouse coordinate in pixels
-- @return Table(Sheet) Pointer to sheet pointed by cursor, nil if no sheet is pointed.
--------------------------------------------------------------------------------
function Sheet:mouseMoved( mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	-- Iterate child sheets.
	for index, sheet in ipairs(self.sheets) do
		local pointed = sheet:mouseMoved( mouseNewX, mouseNewY, mouseOldX, mouseOldY );
		if( pointed ~= nil) then
			return pointed;
		end;
	end;

	if( (self.active==true) and (self:isInside( mouseNewX, mouseNewY )==true) ) then
		return self;
	else
		return nil;
	end;
end;

--------------------------------------------------------------------------------
-- Returns the screen positions (in pixels) of this sheet's corners.
-- @return number Top left X
-- @return number Top left Y
-- @return number Top right X
-- @return number Top right Y
-- @return number Bottom right X
-- @return number Bottom right Y
-- @return number Bottom left X
-- @return number Bottom right Y
--------------------------------------------------------------------------------
function Sheet:getCorners()
	return
		self.absolutePos.x, self.absolutePos.y,
		self.absolutePos.x + self.w, self.absolutePos.y,
		self.absolutePos.x + self.w, self.absolutePos.y+self.h,
		self.absolutePos.x, self.absolutePos.y + self.h;
end;

--------------------------------------------------------------------------------
-- Returns <w,h> the dimensions of this sheet (in pixels)
-- @return w number Width.
-- @return h number Height.
--------------------------------------------------------------------------------
function Sheet:getDimensions()
	return self.w, self.h;
end

--------------------------------------------------------------------------------
-- Resize this sheet by dragging an edge.
-- @param horizontalChange Number - how many pixels were added/removed from horizontal size
-- @param verticalChange Number - how many pixels were added/removed from horizontal size
-- @param verticalEdge Enum(edges) - specifies which edge is being dragged.
-- @param horizontalEdge Enum(edges) - specifies which edge is being dragged.
--------------------------------------------------------------------------------
function Sheet:resize( horizontalChange, verticalChange, verticalEdge, horizontalEdge )
	-- Apply the horizontal resize
	self.w = self.w + horizontalChange;
	-- If the left edge is dragged, the sheet's x offset must change along with the width
	if( verticalEdge == BDT_GUI.edges.LEFT ) then
		-- Change relative pos, update absolute pos
		self.relativePos.x = self.relativePos.x - horizontalChange;
		self.absolutePos.x = self.parent.absolutePos.x+self.relativePos.x;
	end;

	-- Aplly the vertical resize
	self.h = self.h + verticalChange;
	-- If the top edge is dragged, sheet's y offset must change along with the height
	if( horizontalEdge == BDT_GUI.edges.TOP ) then
		-- Change relative pos, update absolute pos
		self.relativePos.y = self.relativePos.y - verticalChange;
		self.absolutePos.y = self.parent.absolutePos.y+self.relativePos.y;
	end;

	-- Distribute the change
	-- elements have top/left offsets, so those bottom/right anchored
	-- must update offsets to keep the right position
	for index, sheet in ipairs(self.sheets) do
		--print("<sheet:resize> func:"..tostring(sheet.parentChanged));
		--sheet:parentChanged( 0, 0, verticalEdge, horizontalEdge );
		sheet:parentChanged( horizontalChange, verticalChange, verticalEdge, horizontalEdge );
	end;
end;

--------------------------------------------------------------------------------
-- Move the sheet and notify child sheets.
-- @param moveX Number - movement offset
-- @param moveY Number - movement offset
--------------------------------------------------------------------------------
function Sheet:move( moveX, moveY )
	--print("<Sheet:move> x:"..tostring(moveX).." y:"..tostring(moveY));
	-- Update relative postion
	self.relativePos.x = self.relativePos.x+moveX;
	self.relativePos.y = self.relativePos.y+moveY;

	-- Update absolute postitions
	self.absolutePos.x = self.parent.absolutePos.x+self.relativePos.x;
	self.absolutePos.y = self.parent.absolutePos.y+self.relativePos.y;

	-- Forward the change
	for index, sheet in ipairs(self.sheets) do
		sheet:parentChanged();
	end;
end;

function Sheet:draw()
	if self.renderer then
		self.renderer:draw(self);
	end
	-- Draw child sheets
	for index, sheet in ipairs(self.sheets) do
		sheet:draw();
	end;
end;

function Sheet:isMouseOver()
	return self.mouseIsOver;
end

function Sheet:isMouseDown()
	return self.mouseIsDown;
end

--------------------------------------------------------------------------------
-- Associates a renderer object with this sheet.
-- @param r SheetRenderer
--------------------------------------------------------------------------------
function Sheet:attachRenderer(r)
	if BDT_GUI.isInstanceOfSheetRenderer(r) then
		self.renderer = r;
		r:attachSheet(self);
	else
		print("WARNING: BDT_GUI.Sheet:attachRenderer: Supplied object is not a renderer, but "..BDT.toString(r));
	end
end

function Sheet:getRenderer()
	return self.renderer;
end

--------------------------------------------------------------------------------
-- (De)activates this sheet. Only active sheet responds to mouse.
-- @param v boolean Activity value.
--------------------------------------------------------------------------------
function Sheet:setActive(v)
	if v ~= self.active then
		self.active = v;
		if self.renderer then
			self.renderer:sheetActivationEvent(v);
		end
	end
end

--------------------------------------------------------------------------------
-- Tells if this sheet has any children.
-- @return Boolean; True if there are child sheets.
--------------------------------------------------------------------------------
function Sheet:hasChildren()
	return #self.sheets>0
end

--------------------------------------------------------------------------------
-- Returns text description of this object.
--------------------------------------------------------------------------------
function Sheet:toString()
   local desc = self.name and self.name or tostring(self);
   return "BDT_GUI.Sheet["..desc..","..tostring(self).."]";
end

--------------------------------------------------------------------------------
-- Checks if supplied object is a Sheet
-- @return boolean True if it's a sheet.
--------------------------------------------------------------------------------
function BDT_GUI.isInstanceOfSheet(o)
	return BDT.isTableAndHasFunctions(o,
		"attachRenderer","draw","move","resize","getCorners","setActive")
end

end;

-- TRASH

-- 'call' method overloads for the 'CallbackList' obejcts.
--[[OBSOLETE
local call = {};

function call.mouseButtonEvent( self, x, y, button )
	for index, callbackFunction in ipairs( self.list ) do
		callbackFunction( self.sheet, x, y, button );
	end;
end;

function call.dragEvent( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY, buttons )
	for index, callbackFunction in ipairs( self.list ) do
		callbackFunction( self.sheet, mouseNewX, mouseNewY, mouseOldX, mouseOldY, buttons );
	end;
end;

]]

--[[FIXME: OBSOLETE THIS

-- Callback functions which set the sheet's state (to make coloring work ok)
local function setMouseOver( self )
	 self.mouseIsOver = true;
end;
local function setMouseOut( self )
	self.mouseIsOver = false;
	self.mouseIsDown = false;
end;
local function setMouseDown( self )
	self.mouseIsDown = true;
end;
local function setMouseUp( self )
	self.mouseIsDown = false;
end;
]]

--[[ DEPRECATED
function Sheet:move( moveX, moveY )
	-- Update relative postion
	self.relativePos.x = self.relativePos.x+moveX;
	self.relativePos.y = self.relativePos.y+moveY;

	-- Update absolute postitions
	self.absolutePos.x = self.parent.absolutePos.x+self.relativePos.x;
	self.absolutePos.y = self.parent.absolutePos.y+self.relativePos.y;
end;
--]]
