-- BDT_GUI_arrange
-- these functions define the positioning and scaling behaviour of a sheet
-- each sheet must have one attached as 'parentChanged'
-- the default is 'fixedPosAndScale'
--[[
Options:
	fixedPosAndScale
	relativePosAndScale
	relativePosFixedScale
	fixedPosLinkedScale
	fixedPosRelativeScale
	custom
--]]

return function( BDT_GUI )

local arrange = {};

--- Reflect the resize or move of the parent
-- Sheet offsets are always top-left anchored, so bottom/right anchored elements
-- must move to keep their correct postions
function arrange.fixedPosAndScale(
		self, horizontalChange, verticalChange, verticalEdge, horizontalEdge )
	if( horizontalChange and BDT_GUI.edges.RIGHT == self.anchor.vertical ) then
		-- Update relative postition
		self.relativePos.x = self.relativePos.x + horizontalChange;
	end;
	if( verticalChange and BDT_GUI.edges.BOTTOM == self.anchor.horizontal ) then
		-- Update relative position
		self.relativePos.y = self.relativePos.y + verticalChange;
	end;
	-- Update absolute postitions
	self.absolutePos.x = self.parent.absolutePos.x+self.relativePos.x;
	self.absolutePos.y = self.parent.absolutePos.y+self.relativePos.y;
	-- Forward the change (sheets must update absolute positions)

	for index,sheet in ipairs(self.sheets) do
		--print("<sheet:parentChanged> func:"..tostring(sheet.parentChanged));
		sheet:parentChanged( 0, 0, verticalEdge, horizontalEdge );
	end;

end;

function arrange.relativePosAndScale(
		self, horizontalChange, verticalChange, verticalEdge, horizontalEdge )
	--[[
	print("<parentChangedRelativePos> horizontalChange, verticalChange:",
		horizontalChange, verticalChange);
	print("<parentChangedRelativePos> relativePosXY WH:",
		self.relativePos.x,self.relativePos.y,self.w,self.h );
	--]]
	local thisSheetHorizontalChange, thisSheetVerticalChange;
	if( horizontalChange ) then
		-- Update relative postition and size
		local relativeChange = horizontalChange/(self.parent.w-horizontalChange);
		thisSheetHorizontalChange = relativeChange*self.w;
		self.w = self.w + thisSheetHorizontalChange;
		self.relativePos.x = self.relativePos.x + self.relativePos.x*relativeChange;

	end;
	if( verticalChange ) then
		-- Update relative position and size
		local relativeChange = verticalChange/(self.parent.h-verticalChange);
		thisSheetVerticalChange = relativeChange*self.h;
		self.h = self.h + thisSheetVerticalChange;
		self.relativePos.y = self.relativePos.y + self.relativePos.y*relativeChange;

	end;
	-- Update absolute postitions
	self.absolutePos.x = self.parent.absolutePos.x+self.relativePos.x;
	self.absolutePos.y = self.parent.absolutePos.y+self.relativePos.y;
	-- Forward the change (sheets must update absolute positions)
	for index,sheet in ipairs(self.sheets) do
		sheet:parentChanged(
			thisSheetHorizontalChange, thisSheetVerticalChange,
			verticalEdge, horizontalEdge );
	end;
end;

-- Modified BDT_GUI:sheet:parentChanged function
-- makes position relative.
function arrange.relativePosFixedScale(
		self, horizontalChange, verticalChange, verticalEdge, horizontalEdge )
	--[[
	print("<parentChangedRelativePos> horizontalChange, verticalChange:",
		horizontalChange, verticalChange);
	print("<parentChangedRelativePos> relativePosXY WH:",
		self.relativePos.x,self.relativePos.y,self.w,self.h );
	--]]
	if( horizontalChange ) then
		-- Update relative postition and size
		local relativeChange = horizontalChange/(self.parent.w-horizontalChange);
		--self.w = self.w + relativeChange*self.w;
		self.relativePos.x = self.relativePos.x + (self.relativePos.x*relativeChange)
			+(self.w/2)*relativeChange;

	end;
	if( verticalChange ) then
		-- Update relative position and size
		local relativeChange = verticalChange/(self.parent.h-verticalChange);
		--self.h = self.h + relativeChange*self.h;
		self.relativePos.y = self.relativePos.y + (self.relativePos.y*relativeChange)
			+(self.h/2)*relativeChange;

	end;
	-- Update absolute postitions
	self.absolutePos.x = self.parent.absolutePos.x+self.relativePos.x;
	self.absolutePos.y = self.parent.absolutePos.y+self.relativePos.y;
	-- Forward the change (sheets must update absolute positions)
	for index,sheet in ipairs(self.sheets) do
		sheet:parentChanged( 0, 0, verticalEdge, horizontalEdge );
	end;
end;

-- Modified BDT_GUI:sheet:parentChanged function, makes it scale along with the parent sheet.
function arrange.fixedPosLinkedScale(
		self, horizontalChange, verticalChange, verticalEdge, horizontalEdge )
	if( horizontalChange and BDT_GUI.edges.RIGHT == self.anchor.vertical ) then
		-- Update relative postition
		self.relativePos.x = self.relativePos.x + horizontalChange;
	end;
	if( verticalChange and BDT_GUI.edges.BOTTOM == self.anchor.horizontal ) then
		-- Update relative position
		self.relativePos.y = self.relativePos.y + verticalChange;
	end;
	-- Update absolute postitions
	self.absolutePos.x = self.parent.absolutePos.x+self.relativePos.x;
	self.absolutePos.y = self.parent.absolutePos.y+self.relativePos.y;
	-- Update scale
	self.w = self.w+(horizontalChange or 0);
	self.h = self.h+(verticalChange or 0);
	-- Forward the change (sheets must update absolute positions)
	for index,sheet in ipairs(self.sheets) do
		sheet:parentChanged( horizontalChange, verticalChange, verticalEdge, horizontalEdge );
	end;
end;


function arrange.fixedPosRelativeScale(
		self, horizontalChange, verticalChange, verticalEdge, horizontalEdge )
	--[[
	print("<parentChangedRelativePos> horizontalChange, verticalChange:",
		horizontalChange, verticalChange);
	print("<parentChangedRelativePos> relativePosXY WH:",
		self.relativePos.x,self.relativePos.y,self.w,self.h );
	--]]
	local thisSheetHorizontalChange, thisSheetVerticalChange;
	if( horizontalChange and horizontalChange ~= 0 ) then
		-- Update relative postition and size
		local relativeChange = horizontalChange/(self.parent.w-horizontalChange);
		thisSheetHorizontalChange = relativeChange*self.w;
		self.w = self.w + thisSheetHorizontalChange;
		--self.relativePos.x = self.relativePos.x + self.relativePos.x*relativeChange;

	end;
	if( verticalChange and verticalChange ~= 0 ) then
		-- Update relative position and size
		local relativeChange = verticalChange/(self.parent.h-verticalChange);
		thisSheetVerticalChange = relativeChange*self.h;
		self.h = self.h + thisSheetVerticalChange;
		--self.relativePos.y = self.relativePos.y + self.relativePos.y*relativeChange;

	end;
	-- Update absolute postitions
	self.absolutePos.x = self.parent.absolutePos.x+self.relativePos.x;
	self.absolutePos.y = self.parent.absolutePos.y+self.relativePos.y;
	-- Forward the change (sheets must update absolute positions)
	for index,sheet in ipairs(self.sheets) do
		sheet:parentChanged(
			thisSheetHorizontalChange, thisSheetVerticalChange,
			verticalEdge, horizontalEdge );
	end;
end;

-- Creates a custom arrangement function from individual X and Y functions
function arrange.custom( changeXFunction, changeYFunction )
	if (type(changeXFunction) ~= "function") then
		changeXFunction = function() end;
	end;
	if (type(changeYFunction) ~= "function") then
		changeYFunction = function() end;
	end;
	return function( self, changeX, changeY, edgeX, edgeY )
		local childChangeX = changeXFunction( self, changeX, edgeX );
		local childChangeY = changeYFunction( self, changeY, edgeY );
		for index,sheet in ipairs(self.sheets) do
			sheet:parentChanged( childChangeX, childChangeY, edgeX, edgeY );
		end;
	end;
end;

arrange.x = {};
arrange.y = {};

-- Versions for one axis only
--- Reflect the resize or move of the parent
-- Sheet offsets are always top-left anchored, so bottom/right anchored elements
-- must move to keep their correct postions

---- Fixed pos and scale ----
function arrange.x.fixedPosAndScale( self, change, edge )
	if( change and change~=0 and BDT_GUI.edges.RIGHT == self.anchor.vertical ) then
		-- Update relative postition
		self.relativePos.x = self.relativePos.x + change;
	end;
	-- Update absolute postitions
	self.absolutePos.x = self.parent.absolutePos.x+self.relativePos.x;
	-- Return nil - child sheets only have to update their absolute positions
end;

function arrange.y.fixedPosAndScale( self, change, edge )
	if( change and change~=0 and BDT_GUI.edges.BOTTOM == self.anchor.horizontal ) then
		-- Update relative postition
		self.relativePos.y = self.relativePos.y + change;
	end;
	-- Update absolute postitions
	self.absolutePos.y = self.parent.absolutePos.y+self.relativePos.y;
	-- Return nil - child sheets only have to update their absolute positions
end;

---- Relative pos and scale ----

function arrange.x.relativePosAndScale( self, change, edge )
	local thisSheetChange;
	if( change and change~=0 ) then
		-- Update relative postition and size
		local relativeChange = change/(self.parent.w-change);
		thisSheetChange = relativeChange*self.w;
		self.w = self.w + thisSheetChange
		self.relativePos.x = self.relativePos.x + self.relativePos.x*relativeChange;
	end;
	self.absolutePos.x = self.parent.absolutePos.x+self.relativePos.x;
	return thisSheetChange;
end;

function arrange.y.relativePosAndScale( self, change, edge )
	local thisSheetChange;
	if( change and change~=0 ) then
		-- Update relative postition and size
		local relativeChange = change/(self.parent.h-change);
		thisSheetChange = relativeChange*self.h;
		self.h = self.h + thisSheetChange
		self.relativePos.y = self.relativePos.y + self.relativePos.y*relativeChange;
	end;
	self.absolutePos.y = self.parent.absolutePos.y+self.relativePos.y;
	return thisSheetChange;
end;

---- Relative pos fixed scale ----

function arrange.x.relativePosFixedScale( self, change, edge )
	if( change and change~=0 ) then
		-- Update relative postition and size
		local relativeChange = change/(self.parent.w-change);
		self.relativePos.x = self.relativePos.x + (self.relativePos.x*relativeChange)
			+(self.w/2)*relativeChange;
	end;
	self.absolutePos.x = self.parent.absolutePos.x+self.relativePos.x;
	-- return nil
end;

function arrange.y.relativePosFixedScale( self, change, edge )
	if( change and change~=0 ) then
		-- Update relative postition and size
		local relativeChange = change/(self.parent.h-change);
		self.relativePos.y = self.relativePos.y + (self.relativePos.y*relativeChange)
			+(self.h/2)*relativeChange;
	end;
	self.absolutePos.y = self.parent.absolutePos.y+self.relativePos.y;
	-- return nil
end;

---- Absolute pos, linked scale ----

function arrange.x.fixedPosLinkedScale( self, change, edge )
	if( change and change~=0 and BDT_GUI.edges.RIGHT == self.anchor.vertical ) then
		-- Update relative postition
		self.relativePos.x = self.relativePos.x + change;
	end;
	-- Update absolute postition
	self.absolutePos.x = self.parent.absolutePos.x+self.relativePos.x;
	-- Update scale
	self.w = self.w+(change or 0);
	return change;
end;

function arrange.y.fixedPosLinkedScale( self, change, edge )
	if( change and change~=0 and BDT_GUI.edges.BOTTOM == self.anchor.horizontal ) then
		-- Update relative postition
		self.relativePos.y = self.relativePos.y + change;
	end;
	-- Update absolute postition
	self.absolutePos.y = self.parent.absolutePos.y+self.relativePos.y;
	-- Update scale
	self.h = self.h+(change or 0);
	return change;
end;

---- Fixed pos, relative scale

function arrange.x.fixedPosRelativeScale( self, change, edge )
	local thisSheetChange;
	if( change and change~=0 ) then
		-- Update relative postition and size
		local relativeChange = change/(self.parent.w-change);
		thisSheetChange = relativeChange*self.w;
		self.w = self.w + thisSheetChange;
		--self.relativePos.x = self.relativePos.x + self.relativePos.x*relativeChange;
	end;
	self.absolutePos.x = self.parent.absolutePos.x+self.relativePos.x;
	return thisSheetChange;
end;

function arrange.y.fixedPosRelativeScale( self, change, edge )
	local thisSheetChange;
	if( change and change~=0 ) then
		-- Update relative postition and size
		local relativeChange = change/(self.parent.h-change);
		thisSheetChange = relativeChange*self.h;
		self.h = self.h + thisSheetChange;

	end;
	self.absolutePos.y = self.parent.absolutePos.y+self.relativePos.y;
	return thisSheetChange;
end;

BDT_GUI.arrangement = arrange;

end; -- End of closure