--------------------------------------------------------------------------------
-- @class table
-- @name class Desk
-- @description A Desk object is a root element of the sheet hierarchy; Also serves as a GUI manager object.
-- @field buttons Table; Buttons pressed above the currently pointed sheet
-- @field buttons.right Boolean; tells if right mouse button is pressed
-- @field buttons.middle Boolean; tells if middle mouse button is pressed
-- @field buttons.left Boolean; tells if left mouse button is pressed
-- @field pointedSheet BDT_GUI.Sheet Sheet currently hovered by mouse.
--------------------------------------------------------------------------------

return function( BDT_GUI ) -- enclosing function

local Desk = {};
Desk.__index = Desk; -- Desk can be used as metatable
Desk.__tostring = function()
	return "BDT_GUI.Desk"
end

--------------------------------------------------------------------------------
-- A callback for a mouse motion event.
-- LOVE 0.6.x does not contain motion event, only button press event.
-- Maybe it will be added in the future, for now it must be called by the user.
-- @param newX New mouse coordinate in pixels
-- @param newY New mouse coordinate in pixels
-- @param oldX Old mouse coordinate in pixels
-- @param oldY Old mouse coordinate in pixels
--------------------------------------------------------------------------------
function Desk:mouseMoved( newX, newY, oldX, oldY )
	--print("<desk:mousemoved>====\n old x:"..oldX.." y:"..oldY.." new x:"..newX.." y:"..newY);
	local lastPointedSheet = self.pointedSheet;
	if( lastPointedSheet
			and (self.buttons.left or self.buttons.right or self.buttons.middle) ) then
		--OBSOLETE-PRE-EVENT self.pointedSheet.onDrag:call( newX, newY, oldX, oldY, self.buttons );
		lastPointedSheet:dragEvent(newX,newY,oldX,oldY,self.buttons)
	end;

	-- Iterate child sheets. Break if pointed sheet is found
	local nowPointedSheet;
	for index, sheet in ipairs(self.sheets) do
		nowPointedSheet = sheet:mouseMoved( newX, newY, oldX, oldY );
		--print("<desk:mousemoved> pointedSheet old:"..tostring(self.pointedSheet).." new:"
		--	..tostring(nowPointedSheet));
		if( nowPointedSheet ~= nil ) then
			break;
		end;
	end;
	--[[--#DBG#
	print("IN BDT_GUI.Desk:mouseMoved() "
		.." new[ X:"..tostring(newX).." Y:"..tostring(newY)
		.."], old[ X:"..tostring(newX).." Y:"..tostring(newY).."]");
	--]]--#/DBG#
	-- If pointed sheet changed, execute callbacks and update pointer
	if( nowPointedSheet ~= lastPointedSheet ) then
		if( lastPointedSheet ) then
			--OBSOLETE lastPointedSheet.onMouseOut:call(  );
			lastPointedSheet:mouseOutEvent();
		end
		self.pointedSheet = nowPointedSheet;
		self.pointedSheetMouseDown = false;
		self.dragPointedSheet = false;
		self.pointedSheetMouseOver = false;
		if( nowPointedSheet ~= nil ) then
			--OBSOLETE self.pointedSheet.onMouseOver:call(  );
			--[[--#DBG#
				print("IN BDT_GUI.Desk:mouseMoved() calling "..nowPointedSheet:toString()..":mouseOverEvent()"
				.." new[ X:"..tostring(newX).." Y:"..tostring(newY)
				.."], old[ X:"..tostring(newX).." Y:"..tostring(newY).."]\n\tPointed[ Last:"
				..BDT.toString(lastPointedSheet).." Now:"..nowPointedSheet:toString().."]");--]]
			nowPointedSheet:mouseOverEvent();
		end
	end

	return self.pointedSheet;
end;

--------------------------------------------------------------------------------
-- Mouse button press or mouse wheel turn callback.
-- @param button love.mouse.MouseConstant enum value.
--------------------------------------------------------------------------------
function Desk:mousePressed( x, y, button )

	if( self.pointedSheet ~= nil ) then
		-- Check button state
		if( button==love.mouse_left ) then
			self.buttons.left = true;
		elseif(button==love.mouse_right) then
			self.buttons.right = true;
		else
			self.buttons.middle = true;
		end;
		-- Notify the pointed sheet
		--OLD self.pointedSheet.onMouseDown:call( x, y, button );
		self.pointedSheet:mouseDownEvent();
	end;
end;

--------------------------------------------------------------------------------
-- Mouse button release callback.
-- @param button love.mouse.MouseConstant enum value.
--------------------------------------------------------------------------------
function Desk:mouseReleased( x, y, button )

	if( self.pointedSheet ~= nil ) then
		-- Check button state
		if( button==love.mouse_left ) then
			self.buttons.left = false;
		elseif(button==love.mouse_right) then
			self.buttons.right = false;
		else
			self.buttons.middle = false;
		end;
		-- Notify the pointed sheet
		--OLD self.pointedSheet.onMouseUp:call( x, y, button );
		self.pointedSheet:mouseUpEvent();
	end;
end;
--------------------------------------------------------------------------------
-- Draws the GUI
--------------------------------------------------------------------------------
function Desk:draw()
	-- Draw child sheets
	for index, sheet in ipairs(self.sheets) do
		sheet:draw();
	end;
end;

--------------------------------------------------------------------------------
-- Attaches a sheet into the tree.
-- @param s Sheet The sheet.
--------------------------------------------------------------------------------
function Desk:attachSheet(s)
	if not BDT_GUI.isInstanceOfSheet(s) then
		error("ERROR: Desk:attachSheet(): Supplied object ["..tostring(s).."] is not a Sheet");
	end
	table.insert(self.sheets,s);
end

function Desk:detachSheet(s)

end

--------------------------------------------------------------------------------
-- Creates a new Sheet object as a child of this desk.
-- @name Desk:newSheet
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
Desk.newSheet = BDT_GUI._newSheet;

--------------------------------------------------------------------------------
-- Detaches a sheet object from this desk.
-- @name Desk:removeSheet
-- @class function
-- @param indexOrPointer A numeric index or a pointer to the sheet which should be removed.
--------------------------------------------------------------------------------
Desk.removeSheet = BDT_GUI.removeSheet;

--------------------------------------------------------------------------------
-- Fetches the Sheet which mouse currently points to
-- @return table
--------------------------------------------------------------------------------
function Desk:getPointedSheet()
	return self.pointedSheet;
end

--------------------------------------------------------------------------------
-- Constructor of 'Desk' instances
--------------------------------------------------------------------------------
function BDT_GUI.newDesk()
	return setmetatable(
	{
		sheets = {};
		absolutePos = {x=0, y=0};
		-- The sheet curently hovered by mouse
		pointedSheet = nil;
		-- Buttons pressed above the currently pointed sheet
		buttons = {
			right=false;
			middle=false;
			left=false;
		};

		-- True if the currently pointed sheet should be dragged
		-- Is set by dragPointedSheet() method.
	},
	Desk
	);
end;

end; -- End of enclosing function