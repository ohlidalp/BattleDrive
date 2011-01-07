--[[
________________________________________________________________________________

                                                                         BD_Grob
                                                                 Version: Beta 2
                                                       Compatibility: LOVE 0.5.0
                         Copyright (C) 2008-2009 Petr Ohlidal <An00biS@email.cz>

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

A grob is an object that encapsulates an organized set of sprites which
together form a pseudo-3D rotating graphical entity, useful for games.

_________________________________ Reference ____________________________________

--------------------------------------------------------------------------------
-- @class table
-- @name BDT_Grob package
-- @description A grob is an object that encapsulates an organized set of sprites which together form a pseudo-3D rotating graphical entity, useful for games.
-- @field ANGLE_UPDATE_FOLLOW Designates the grob's reaction to rotation of it's parent; Grob rotates along (default)
-- @field ANGLE_UPDATE_IGNORE Ditto; Grob ignores the rotation
-- @field ANGLE_UPDATE_SKIP Ditto; Grob ignores the update, but passes it to it's child grobs.
--------------------------------------------------------------------------------
]]

-- -- Optimization ----
local love = love;
local graphics = love.graphics;

-- -- Config ----
local cfgDrawPivotLineColor = {255,255,0,255}
local cfgDrawPegLineColor = {0,0,255,255}
local cfgDrawPegFloorLineColor = {0,255,255,255}
local cfgDrawPegEdgeX = 10;
local cfgDrawPegEdgeY = 10;

-- -- Utils -----
-- Conversion constant
local DEGREES_IN_RADIAN = (180/math.pi);
local _2PI = 2*math.pi;

--- Restrains any angle to 0-355 bounds.
local function restrainAngleDegrees(angle)
	if angle<0 or angle>=360 then
		return angle%360;
	else
		return angle;
	end
end;
-- Checks an argument
local function checkArg(funcName, arg, argi, expected)
	if type(arg)~=expected then
		error("<"..funcName.."> : Invalid argument #"..argi..": "
			..expected.." expected, got "..type(arg));
	end
end

local function DBG_getGrobName(grob)
	return (type(grob)=="table" and tostring(grob.name) or "!NOT A GROB!:"..type(grob));
end
-- Debug utility: sets how much should be the output indented
local G_tabs = "";
local function tabsIncrement()
	G_tabs = G_tabs.."\t";
end
local function tabsDecrement()
	local len = string.len(G_tabs);
	if len>0 then
		G_tabs = string.sub(G_tabs, 1, len-1);
	end
end
local function tabsPrint(s)
	print(G_tabs..s);
end


-- ------------------------------ Constants ------------------------------------

-- Designates the grob's reaction to rotation of it's parent
local ANGLE_UPDATE_FOLLOW = 1 -- Grob rotates along (default)
local ANGLE_UPDATE_IGNORE = 2 -- Grob ignores the rotation
local ANGLE_UPDATE_SKIP = 3 -- Grob ignores the update, but passes it to it's child grobs.

-- ------------------------- Angle manipulations -------------------------------
-- RULE: methods using radians are frontends for methods using degrees.

--------------------------------------------------------------------------------
-- @class table
-- @name class Grob
-- @description Common grob logic.
-- @field noAngles number Number of visual angles this grob can present.
-- @field spriteIndex number The current visual angle (sprite index) ( from 1 to noAngles )
-- @field angle number Grob's angle in degrees, 0 being straight down.
-- @field pegs Table { { name, position/positions } } Array of pegs; A peg is a point defined on the grob with regard to it's rotation; There is either a single PegOffset for all angles or one PegOffset per angle; PegOffset is a {x,y,h} table, where x and y are the offset from pivot point and h is the height (y distance from ground level).
-- @field imageAreas Table{ {x1, y1, x2, y2} } Areas which this grob's sprites occupy on the map, defined as AABBs; Field's not present if 'singleImageArea' is defined.
-- @field singleImageArea Table{x1, y1, x2, y2} Areas which this grob's sprite occupies on the map, defined as AABB; Field's not present if 'imageAreas' is defined.
-- @field children table{ [: SubGrob/False :] } Grobs attached to this one as child grobs; Table index = peg index -1 (slot #1 is reserved for pivot-mounted grob); This table is allways preallocated with "false" values (to enable ipairs())
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Rotation function; Updates the grob's angle and spriteIndex
-- @class function
-- @name Grob:rotateDegrees
-- @param deltaAngle number Angle to rotate in degrees; Positive number rotates clockwise, negative counterclockwise.
-- @param updateChildGrobs boolean Sets if the operation lso updates child grobs; default true.
--------------------------------------------------------------------------------
local function Grob__rotateDegrees(self,deltaAngle,updateChildGrobs)
	updateChildGrobs = updateChildGrobs or true;

	local newAngle = restrainAngleDegrees(self.angle+deltaAngle);
	-- Compute new vis angle
	local newVisAngle, rem = math.modf(newAngle/(360/self.noAngles));
	newVisAngle = (rem<0.5) and newVisAngle+1 or newVisAngle+2;
	if newVisAngle>self.noAngles then
		newVisAngle = newVisAngle-self.noAngles;
	end
	-- Compute vis angle change
	local visAngleChange = newVisAngle-self.spriteIndex;
	if deltaAngle>0 and visAngleChange<0 then
		visAngleChange = self.noAngles+visAngleChange;
	elseif deltaAngle<0 and visAngleChange>0 then
		visAngleChange = visAngleChange-self.noAngles;
	end
	-- Set angle
	self.angle = newAngle;
	-- Set vis angle
	self.spriteIndex = newVisAngle;

	--[[
	print(string.format("<Grob__rotateDegrees>\n"
		.."\t name:%s"
		.."\n\t delta:%0.3f"
		.." newAngle:%0.3f"
		.." newVisAngle:%.2f"
		.."\n\t visAngleChange:%.2f"
		.." #children:%d"
		.." spriteIndex:%0.3f",
		self.name,
		deltaAngle,
		newAngle,
		newVisAngle,
		visAngleChange,
		#self.children,
		self.spriteIndex));
	--]]
	-- Update child grobs
	if updateChildGrobs and #self.children>0 then
		for index, grobOrBoolean in ipairs(self.children) do
			if grobOrBoolean then
				grobOrBoolean:parentRotated( deltaAngle, visAngleChange );
			end
		end
	end
	-- Return vis angle change
	return visAngleChange;
end

--------------------------------------------------------------------------------
-- Rotation function; Updates the grob's angle and spriteIndex; frontend to 'rotateDegrees'
-- @class function
-- @name Grob:rotateRadians
-- @param deltaAngle number Angle to rotate in radians; Positive number rotates clockwise, negative counterclockwise.
-- @param updateChildGrobs boolean Sets if the operation lso updates child grobs; default true.
--------------------------------------------------------------------------------
local function Grob__rotateRadians(self,deltaAngle,updateChildGrobs)
	--[[
		print("<Grob__rotateRadians>\n\tname:"..self.name.."\n\t deltaAngle:"..tostring(deltaAngle));
	--]]
	self:rotateDegrees(deltaAngle*DEGREES_IN_RADIAN, updateChildGrobs);
end;

--------------------------------------------------------------------------------
-- Get the angle of the current sprite
-- @class function
-- @name Grob:getVisualAngleDegrees
-- @param none nil
-- @return number angle of the current sprite in degrees
--------------------------------------------------------------------------------
local function Grob__getVisualAngleDegrees(self)
	return (self.spriteIndex-1)*(360/self.noAngles)
end;

--------------------------------------------------------------------------------
-- Get the angle of the current sprite
-- @class function
-- @name Grob:getVisualAngleRadians
-- @param none nil
-- @return number angle of the current sprite in radians
--------------------------------------------------------------------------------
local function Grob__getVisualAngleRadians(self)
	return self:getVisualAngleDegrees()/DEGREES_IN_RADIAN
end;

--------------------------------------------------------------------------------
-- Angle setter function (uses rotation function, rotates in positive dir); Frontend to setAngleDegrees().
-- @class function
-- @name Grob:setAngleRadians
-- @param angle number target angle in radians
-- @return number Visual angle change
--------------------------------------------------------------------------------
local function Grob__setAngleRadians(self, angle)
	return self:setAngleDegrees(angle*DEGREES_IN_RADIAN)
end;

--------------------------------------------------------------------------------
-- Angle setter function (uses rotation function, rotates in positive dir).
-- @class function
-- @name Grob:setAngleDegrees
-- @param angle number target angle in degrees
-- @return number Visual angle change
--------------------------------------------------------------------------------
local function Grob__setAngleDegrees(self, angle)
	return self:rotateDegrees( (self.angle<angle) and angle-self.angle or self.angle-angle );
end;

--------------------------------------------------------------------------------
-- Angle getter function
-- @class function
-- @name Grob:getAngleDegrees
-- @return number Grob's current angle in degrees.
--------------------------------------------------------------------------------
local function Grob__getAngleDegrees(self)
	return self.angle;
end;

--------------------------------------------------------------------------------
-- Angle getter function
-- @class function
-- @name Grob:getAngleRadians
-- @return number Grob's current angle in radians
--------------------------------------------------------------------------------
local function Grob__getAngleRadians(self)
	return self.angle/DEGREES_IN_RADIAN
end

--------------------------------------------------------------------------------
-- Returns index of current visual angle
-- @class function
-- @name Grob:getVisualAngleIndex
-- @return number index of current visual angle
--------------------------------------------------------------------------------
local function Grob__getVisualAngleIndex(self)
	return self.spriteIndex;
end

--------------------------------------------------------------------------------
-- Visualizes pivot and peg points.
-- @class function
-- @name Grob:drawPoints
-- @param screenX Grob's X position on the screen
-- @param screenY Grob's Y position on the screen
--------------------------------------------------------------------------------
local function Grob__drawPoints(self, screenX, screenY)
	-- Optimization
	local love = love;
	local graphics = love.graphics;
	local setColor = graphics.setColor;
	local line = graphics.line;
	-- Environment
	local envColor = graphics.getColor();
	-- Drawing pegs
	local noPegs = self:getPegCount();
	local floorColor = cfgDrawPegFloorLineColor;
	local pegColor = cfgDrawPegLineColor;
	local pegX = cfgDrawPegEdgeX;
	local pegY = cfgDrawPegEdgeY;
	for i = 1, noPegs, 1 do
		local x,y,h = self:getPegOffset(i);
		x=x+screenX;
		y=y+screenY;
		-- Draw floor
		setColor(floorColor);
		line(x-pegX, (y-pegY)+h, x+pegX, (y+pegY)+h);
		line(x+pegX, (y-pegY)+h, x-pegX, (y+pegY)+h);
		-- Draw peg
		setColor(pegColor);
		line(x-pegX, y-pegY, x+pegX, y+pegY);
		line(x+pegX, y-pegY, x-pegX, y+pegY);

	end
	-- Environment
	setColor(envColor);
end

--------------------------------------------------------------------------------
-- Returns number of pegs.
-- @class function
-- @name Grob:getPegCount
-- @return number
--------------------------------------------------------------------------------
local function Grob__getPegCount(self)
	return #self.pegs;
end;

--------------------------------------------------------------------------------
-- Querries a peg index by name.
-- @class function
-- @name Grob:getPegIndex
-- @param pegName string
-- @return number
--------------------------------------------------------------------------------
local function Grob__getPegIndex(self,pegIndexOrName)
	if type(pegIndexOrName)=="number" then
		if pegIndexOrName>#self.pegs or pegIndexOrName<0 then
			error("<Grob:getPegIndex> Invalid peg identifier: '"
				..pegIndexOrName.."' ["..#self.pegs.." pegs]");
		end
		return pegIndexOrName;
	elseif type(pegIndexOrName)=="string"then
		for i, p in ipairs(self.pegs) do
			if p.name==pegIndexOrName then
				return i;
			end
		end
		error("<Grob:getPegIndex> Invalid peg identifier: '"..pegIndexOrName.."'");
	else
		error("<Grob:getPegIndex> Invalid argument #1 'pegIndexOrName',"
			.."expected number or string, got "..type(pegIndexOrName));
	end
end

--------------------------------------------------------------------------------
-- Returns a reference to grob's internal pegs table; should be private
-- @class function
-- @name Grob:getPeg
-- @param pegIndexOrName string
-- @return table Peg data
--------------------------------------------------------------------------------
local function Grob__getPeg(self, pegIndexOrName)
	if type(pegIndexOrName)=="number" then
		if pegIndexOrName==0 then
			return false;
		else
			return self.pegs[pegIndexOrName];
		end
	elseif type(pegIndexOrName)=="string" then
		return self.pegs[ self:getPegIndex(pegIndexOrName) ];
	else
		error("<Grob__getPeg> Invalid argument #1 'pegIndexOrName',"
			.."expected number or string, got "..type(pegIndexOrName));
	end
end

--------------------------------------------------------------------------------
-- Returns peg's offset from grob's pivot point
-- @class function
-- @name Grob:getPegOffset
-- @param pegIndexOrName number/string
-- @return number X position
-- @return number Y position
-- @return number Z position (virtual height)
--------------------------------------------------------------------------------
function Grob__getPegOffset(self, pegIndexOrName)
	local pegIndex = self:getPegIndex(pegIndexOrName);
	if pegIndex==0 then
		return 0,0,0;
	end
	local peg = self:getPeg(pegIndex);
	if peg then
		local pegPos;
		if peg.position then
			pegPos = peg.position;
		else
			pegPos = peg.positions[self.spriteIndex];
		end
		return pegPos.x, pegPos.y, pegPos.h;
	else
		error("<Grob__getPegOffset()> Invalid peg identifier '"..tostring(pegIndexOrName)
				.."' ["..self:getPegCount().." pegs].");
	end
end

--------------------------------------------------------------------------------
-- Attaches a child to any grob.
-- @class function
-- @name Grob:attachChild
-- @param subGrob SubGrob The subgrob to attach
-- @param pegIndexOrName number/string The peg to attach the sub-grob to, counting from 1; Passing zero uses the grob's pivot as the peg (useful for shadows and ground-based effects).
-- @return Grob The previous grob on the specified peg.
--------------------------------------------------------------------------------
local function Grob__attachChild(self, subGrob, pegIndexOrName)
	--[[ DBG
	print("<Grob__attachChild>\n\tself:"..self.name.." sub:"
		..subGrob.name.."\n\tpegIndex:"..tostring(pegIndexOrName));
	--]]
	-- Check the peg index
	local pegIndex = self:getPegIndex(pegIndexOrName);
	-- Setup the parent grob
	local oldGrob = self.children[pegIndex];
	self.children[pegIndex+1] = subGrob;
	-- Setup the child grob
	subGrob.pegIndex = pegIndex;
	subGrob.parentGrob = self;
	if subGrob.noAngles == self.noAngles then
		subGrob.synchronizeVisualAngle = true;
	end
	-- Return the old grob
	return oldGrob;
end

--------------------------------------------------------------------------------
-- Removes a child grob
-- @class function
-- @name Grob:removeChild
-- @param grobReference Grob A pointer to the grob.
-- @return Grob The grob on success, or false if it wasn't found.
--------------------------------------------------------------------------------
local function Grob__removeChild(self, grobReference)
	for index, childGrob in ipairs(self.children) do
		if childGrob and childGrob==grobReference then
			self.children[index] = false;
			return grobReference;
		end
	end
	return false;
end;

--------------------------------------------------------------------------------
-- Returns <x,y,h> the grob's map position (in pixels)
-- @class function
-- @name Grob:getPosition
-- @param none nil
-- @return number X position
-- @return number Y position
-- @return number Z position (virtual height)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Returns <x,y> the map position (in pixels). Height is substracted from Y.
-- @class function
-- @name Grob:getPositionXY
-- @param none nil
-- @return number X position
-- @return number Y position
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- returns <x1, y1, x2, y2>, area which this grob visually occupies on the map (in pixels); Only considers one grob, even if it's the root; To get the complete area occupied by a grob hierarchy, use RootGrob__getFullImageArea()
-- @class function
-- @name Grob:getImageArea
-- @param none nil
-- @return number X1 (top border)
-- @return number Y1 (left border)
-- @return number X2 (bottom border)
-- @return number X2 (right border)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- returns <x,y,h> absolute map position of a grob's peg, plus its height
-- @class function
-- @name Grob:getPegPosition
-- @param pegIndexOrName string/number 0 means the grob's pivot
-- @return number X position
-- @return number Y position
-- @return number Z position (virtual height)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- returns <x,y,h> peg's offset from the root grob's pivot
-- @class function
-- @name Grob:getPegRootOffset
-- @param pegIndexOrName string/number 0 means the grob's pivot
-- @return number X offset
-- @return number Y offset
-- @return number Z offset (virtual height)
--------------------------------------------------------------------------------
local RootGrob__getPegRootOffset = Grob__getPegOffset;

--------------------------------------------------------------------------------
-- Fetches a child grob.
-- @class function
-- @name Grob:getChild
-- @param pegIndexOrName string/number Numeric index (counted from 1) or name of the peg.
-- @return Grob The child grob.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Callback to notify the root grob about new sub-grob.
-- @class function
-- @name Grob:childAdded
-- @param grob Grob The added subgrob.
-- @param drawPriority number
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Callback to notify the root grob about removed sub-grob
-- @class function
-- @name Grob:childRemoved
-- @param grob Grob The removed subgrob.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Renders the grob
-- @class function
-- @name Grob:draw
-- @param x number Grob's screen position
-- @param y number Grob's screen position
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- @class table
-- @name class RootGrob extends Grob
-- @description Root object of grob tree; Can be independently positioned
-- @field x number Map position in pixels
-- @field y number Map position in pixels
-- @field h number Map position in pixels (virtual height, substracts from Y)
-- @field z number the grob's drawing order index (y-axis coordinate of shade's bottom border)
-- @field zMod number Z index modifier. Added to z index to prevent 2 grobs having the same z; Default is 0, sorting functions increase it by 0.1 and less; When 2 grobs have same z and overlap, the drawing order is random; That may create an unpleasant 'blinking' effect.
-- @field drawingOrder table links to all grobs which should be drawn with "draw()" method; The order in this array is the drawing order of the member grobs; 1 = highest priority (drawn first); There is no built-in sorting mechanism for the drawing order.
-- @field singleShade table{x,y,w,h} Shade (in general) = area {x,y,w,h} where grob 'touches the ground'; singleShade = just one shade which applies to all sprites; this field is mutually exclusive with 'shades' field.
-- @field shades table{ Shade } table of shades, one per sprite; this field is mutually exclusive with 'singleShade'
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Angle setter function (uses rotation function, rotates in positive dir); Frontend to setAngleDegrees().
-- @class function
-- @name RootGrob:setAngleRadians
-- @param angle number target angle in radians
-- @param affectChildren boolean Sets whether the change should be distributed; Default=true
-- @return number Visual angle change
--------------------------------------------------------------------------------
local function RootGrob__setAngleRadians(self, angle, affectChildren)
	self:setAngleDegrees(angle*DEGREES_IN_RADIAN, affectChildren);
end;

--------------------------------------------------------------------------------
-- returns <x,y,h> absolute map position of a grob's peg, plus its height
-- @class function
-- @name RootGrob:getPegPosition
-- @param pegIndexOrName string/number 0 means the grob's pivot
-- @return number X position
-- @return number Y position
-- @return number Z position (virtual height)
--------------------------------------------------------------------------------
local function RootGrob__getPegPosition( self,pegIndexOrName )
	local pegX, pegY, pegH = self:getPegOffset(pegIndexOrName);
	return self.x+pegX, self.y+pegY, self.h+pegH;
end;

--------------------------------------------------------------------------------
-- returns <x,y,w,h> the shade's map coordinates and size (in pixels).
-- @class function
-- @name RootGrob:getShade
-- @param pegIndexOrName string/number 0 means the grob's pivot
-- @return number shade's X position
-- @return number shade's Y position
-- @return number shade's width
-- @return number shade's height
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Implementation of 'getShade' for single shade.
--------------------------------------------------------------------------------
local function RootGrob__getShade_SingleShade( self )
	--[[
	print("<RootGrob__getShade_SingleShade( self )>:"..
		"\n\tself.singleShade\n"..tableToString(self.singleShade, "\t\t")
		.."\n\tself.pos:\n"..tableToString(self.pos,"\t\t"));
	--]]
	return
		self.singleShade.x+self.x,
		self.singleShade.y+self.y,
		self.singleShade.w,
		self.singleShade.h;
end;

--------------------------------------------------------------------------------
-- Implementation of 'getShade' for multiple shades.
--------------------------------------------------------------------------------
local function RootGrob__getShade_ShadePerSprite( self )
	--[[
	print("<RootGrob__getShade_ShadePerSprite> self.shades:"
		..tableToString(self.shades)
		.." spriteIndex:"..tostring(self.spriteIndex));
	print("shade:\n"..tableToString(self.shades[self.spriteIndex]));
	print("pos ["..#self.pos.."]:\n"..tableToString(self.pos));
	--]]
	return
		self.shades[self.spriteIndex].x+self.x,
		self.shades[self.spriteIndex].y+self.y,
		self.shades[self.spriteIndex].w,
		self.shades[self.spriteIndex].h;
end;

--------------------------------------------------------------------------------
-- returns <x1, y1, x2, y2>, area which this grob visually occupies on the map (in pixels); Only considers one grob, even if it's the root; To get the complete area occupied by a grob hierarchy, use RootGrob__getFullImageArea()
-- @class function
-- @name Grob:getImageArea
-- @param none nil
-- @return number X1 (top border)
-- @return number Y1 (left border)
-- @return number X2 (bottom border)
-- @return number X2 (right border)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Implementation of 'Grob:getImageArea' for multiple image areas.
--------------------------------------------------------------------------------
local function RootGrob__getImageArea_AreaPerSprite(self)
	--[[
	print("<RootGrob__getImageArea_AreaPerSprite> spriteIndex:",self.spriteIndex);
	print("self:\n"..tableToString(self));
	--]]
	return
		self.x+self.imageAreas[self.spriteIndex].x1,
		self.y+self.imageAreas[self.spriteIndex].y1,
		self.x+self.imageAreas[self.spriteIndex].x2,
		self.y+self.imageAreas[self.spriteIndex].y2;
end;

--------------------------------------------------------------------------------
-- Implementation of 'Grob:getImageArea' for single image area.
--------------------------------------------------------------------------------
local function RootGrob__getImageArea_SingleArea(self)
	return
		self.x+self.singleImageArea.x1,
		self.y+self.singleImageArea.y1,
		self.x+self.singleImageArea.x2,
		self.y+self.singleImageArea.y2;
end;

--------------------------------------------------------------------------------
-- returns <x1, y1, x2, y2>, area which this grob hierarchy can eventually ocuppy, considering all posible angles of all grobs.
-- @class function
-- @name Grob:getMaxImageArea
-- @param none nil
-- @return number X1 (top border)
-- @return number Y1 (left border)
-- @return number X2 (bottom border)
-- @return number X2 (right border)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Implementation of 'Grob:getImageArea' for multiple image areas.
--------------------------------------------------------------------------------
local function RootGrob__getMaxImageArea_AreaPerSprite(self)
	local x1,y1,x2,y2 = 1000000,1000000,-1000000,-1000000;
	for index, area in ipairs(self.imageAreas)do
		x1 = (x1<area.x1) and x1 or area.x1;
		y1 = (y1<area.y1) and y1 or area.y1;
		x2 = (x2>area.x2) and x2 or area.x2;
		y2 = (y2>area.y2) and y2 or area.y2;
	end;
	return x1+self.x, y1+self.y, x2+self.x, y2+self.y;
end;

local RootGrob__getMaxImageArea_SingleArea
		= RootGrob__getImageArea_SingleArea;

--------------------------------------------------------------------------------
-- Returns <x1, y1, x2, y2> the union of areas occupied by grobs in a given hierarchy
-- @class function
-- @name Grob:getFullImageArea
-- @param none nil
-- @return number X1 (top border)
-- @return number Y1 (left border)
-- @return number X2 (bottom border)
-- @return number X2 (right border)
--------------------------------------------------------------------------------
local function RootGrob__getFullImageArea(self)
	local x1min = 10e9;
	local y1min=10e9;
	local x2max=-10e9;
	local y2max=-10e9;
	for index, grob in ipairs(self.drawingOrder) do
		local x1, y1, x2, y2 = grob:getImageArea();
		x1min = x1 < x1min and x1 or x1min;
		y1min = y1 < y1min and y1 or y1min;
		x2max = x2 > x2max and x2 or x2max;
		y2max = y2 > y2max and y2 or y2max;
	end;
	return x1min, y1min, x2max, y2max;
end;

--------------------------------------------------------------------------------
-- Attaches a child to root grob.
-- @class function
-- @name RootGrob:attachChild
-- @param subGrob SubGrob The subgrob to attach
-- @param pegIndexOrName number/string The peg to attach the sub-grob to, counting from 1; Passing zero uses the grob's pivot as the peg (useful for shadows and ground-based effects).
-- @param drawPriority Grob's position in drawing order, counting from 1; 1 = highest priority (drawn first); 0 or nil = lowest priority (drawn last); Negative number means the grob won't be drawn (useful for shadows, which need to be drawn separately).
-- @return Grob The previous grob on the specified peg.
--------------------------------------------------------------------------------
local function RootGrob__attachChild(self, subGrob, pegIndexOrName, drawPriority)
	if type(subGrob) ~= "table" then
		error("RootGrob__attachChild() Invalid argument#1 'subGrob',"
			.." expected table, got "..type(subGrob));
	end;
	local oldGrob = Grob__attachChild(self, subGrob, pegIndexOrName);

	-- If the drawPriority is negative, don't draw the grob at all.
	if not (drawPriority and drawPriority<0) then
		-- If the drawPriority is greater than zero, use it.
		if drawPriority and drawPriority>0 then
			table.insert(self.drawingOrder, drawPriority, subGrob )
		-- If the drawPriority is undefined or zero, give the grob lowest priority (drawn last).
		else
			table.insert(self.drawingOrder, subGrob )
		end
	end

	return oldGrob;
end;

--------------------------------------------------------------------------------
-- Callback; Recieves a notification from subgrob and inserts the new grob into "drawingOrder" list.
-- @class function
-- @name RootGrob:childAdded
-- @param grob Grob The added subgrob.
-- @param drawPriority number Grob's position in drawing order (default=lowest priority=drawn last) (negative priority=the grob's not added).
--------------------------------------------------------------------------------
local function RootGrob__childAdded(self, grob, drawPriority)
	--[[
	print("<RootGrob__childAdded>\n\t self:"..self.name
		.." grob:"..DBG_getGrobName(grob)
		.."\n\t drawPriority:"..tostring(drawPriority)..(drawPriority<0 and " [not drawn]" or "")
		.." #drawingOrder:"..#self.drawingOrder);
	--]]

	if not drawPriority or drawPriority==0 then -- Give the grob lowest priority (drawn last)
		table.insert(self.drawingOrder, grob);
	elseif drawPriority>0 then -- If the priority is greater than zero, use it.
		table.insert(self.drawingOrder,drawPriority, grob );
	end -- If drawPriority is negative, don't add the grob at all.
end;

--------------------------------------------------------------------------------
-- Removes a child grob
-- @class function
-- @name RootGrob:removeChild
-- @param grobReference Grob A pointer to the grob.
-- @return Grob The removed grob on success, or false if it wasn't found.
--------------------------------------------------------------------------------
local function RootGrob__removeChild(self, grobReference)
	if Grob__removeChild(self, grobReference)==false then
		return false;
	end;
	BDT.tableRemoveByValue(self.drawingOrder, grobReference);
	return grobReference;
end;

--------------------------------------------------------------------------------
-- Callback to notify the root grob about removed sub-grob
-- @class function
-- @name Grob:childRemoved
-- @param grobReference Grob The removed subgrob.
--------------------------------------------------------------------------------
local function RootGrob__childRemoved(self, grobReference)
	BDT.tableRemoveByValue(self.drawingOrder, grobReference);
end;

local function RootGrob__getOffset(self)
	return 0, 0, 0;
end;

--------------------------------------------------------------------------------
-- Returns <x,y,h> the grob's map position (in pixels)
-- @class function
-- @name Grob:getPosition
-- @param none nil
-- @return number X position
-- @return number Y position
-- @return number Z position (virtual height)
--------------------------------------------------------------------------------
local function RootGrob__getPosition(self)
	return self.x, self.y, self.h;
end;

-- screenX, screenY - the screen position to draw the grob to
local function RootGrob__draw(self, screenX, screenY)
	local love_graphics_draw = love.graphics.draw;
	--[[ == Debug ==
		tabsPrint("<RootGrob__draw "..self.name..">");
	--]]
	for index, grob in ipairs(self.drawingOrder) do
		--[[ == Debug ==
		tabsIncrement();
		--]]
		local grobX, grobY, grobH = grob:getOffset();
		--[[ == Debug ==
		local sprite = grob.sprites[grob.spriteIndex];
		local pivotX, pivotY, pivotH = grob:getPosition();
		tabsDecrement();
		tabsPrint("\t["..grob.name.."] sprite:"..tostring(sprite)
			..' x'..pivotX.." y"..pivotY.." h"..pivotH);
		if not sprite then
			tabsPrint("\t<DBG sprites> ["..#grob.sprites.."]");
			for i, s in ipairs(grob.sprites) do
				tabsPrint("\t\t"..i..": "..tostring(s));
			end
		end
		--]]
		--OLD love.graphics.draw( grob.sprites[grob.spriteIndex], screenX+grobX, screenY+grobY-grobH );
		local s = grob.sprites[grob.spriteIndex];
		love_graphics_draw(s.image,
			screenX + grobX + s.x,
			screenY + (grobY - grobH) + s.y);
	end;
end;

local function RootGrob__setMapPos(self, x, y)
	self.x, self.y = x, y;
end;

--------------------------------------------------------------------------------
-- Calculates the Z-index for this grob.
-- @class function
-- @name Grob:updateZ
-- @param none nil
--------------------------------------------------------------------------------
local function RootGrob__updateZ(self)
	self.z = (self.singleShade~=nil)
		and self.y+self.zMod
			+self.singleShade.y+self.singleShade.h
		or self.y+self.zMod
			+self.shades[self.spriteIndex].y+self.shades[self.spriteIndex].h;
end;
--============================= subgrob =====================================

--------------------------------------------------------------------------------
-- @class table
-- @name class RootGrob extends Grob
-- @description Root object of grob tree; Can be independently positioned
-- @field parentGrob Grob a pointer to the parent grob.
-- @field pegIndex number Index of the parent grob's peg this SubGrob is attached to.
-- @field displacementX The subgrob's displacement against the parent's peg (X axis)
-- @field displacementY The subgrob's displacement against the parent's peg (Y axis)
-- @field displacementH The subgrob's displacement against the parent's peg (Virtual Z axis = Y axis)
-- @field synchronizeVisualAngle boolean Modifies the visual angle to synchronize rotation with the parent grob (provided it has equal number of visual angles); If two grobs rotate unsynchronized, the parent's and child's sprites change in sequence, like "parent, child, parent, child" and the resulting "vibration" effect is very unpleasant; Only effective with parentRotated callback; Default: True if grobs have equal number of visual angles, false otherwise.
-- @field angleSyncData number Stores the angle difference between unsynchronized angle and synchronized angle; It only needs to be recalculated when this sub-grob rotates itself, otherwise it can be re-used.
-- @field angleInSync boolean Tells if the sync data are valid.
-- @field angleUpdateHandling number One of ANGLE_UPDATE constants, designating the reaction to parent's rotation.
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Callback notifying the grob about parent's angle change
-- @class function
-- @name SubGrob:parentRotated
-- @param deltaAngleDegrees number Parent's angle change.
-- @param visAngleChange number Number of visual angle changes during the rotation; Important for rotation
--------------------------------------------------------------------------------
local function SubGrob__parentRotated(self, deltaAngleDegrees, parentVisAngleChange)
	local thisGrobVisAngleChange;
	if self.angleUpdateHandling == ANGLE_UPDATE_FOLLOW then
		local newAngle = restrainAngleDegrees(self.angle+deltaAngleDegrees);
		--[[
		print(string.format("<SubGrob__parentRotated>\n"
			.."\t name:%s"
			.."\n\t self.angle:%0.4f"
			.." self.spriteIndex:%.2f"
			.." delta:%0.4f"
			.." new-angle:%0.4f"
			.."\n\t parentVisChange:%.2f"
			.." self.synchronizeVisualAngle:%d",
			self.name,
			self.angle,
			self.spriteIndex,
			deltaAngleDegrees,
			newAngle,
			parentVisAngleChange,
			self.synchronizeVisualAngle and 1 or 0));
		--]]
		if self.synchronizeVisualAngle then

			-- Change vis angle as parent
			local newVisAngle = self.spriteIndex+parentVisAngleChange;
			if newVisAngle>self.noAngles then
				--self.spriteIndex = (newVisAngle%self.noAngles)+1;
				self.spriteIndex = newVisAngle-self.noAngles;
			elseif newVisAngle<1 then
				--self.spriteIndex = self.noAngles+(newVisAngle%self.noAngles);
				self.spriteIndex = newVisAngle+self.noAngles;
			else
				self.spriteIndex = newVisAngle;
			end

			-- Set the angle attribute to exact value
			self.angle = restrainAngleDegrees( self.angle+deltaAngleDegrees );
			thisGrobVisAngleChange = parentVisAngleChange;
		else
			-- Update angle and visAngle, but don't affect child grobs.
			thisGrobVisAngleChange = self:rotateDegrees(deltaAngleDegrees, false);
		end
	end
	if #self.children > 0 and
		(self.angleUpdateHandling == ANGLE_UPDATE_FOLLOW or
		self.angleUpdateHandling == ANGLE_UPDATE_SKIP)
	then
		for index, grobOrBoolean in ipairs(self.children) do
			if grobOrBoolean then
				grobOrBoolean:parentRotated(deltaAngleDegrees, thisGrobVisAngleChange);
			end
		end
	end
end

--------------------------------------------------------------------------------
-- returns <x,y,h> absolute map position of a grob's peg, plus its height
-- @class function
-- @name SubGrob:getPegPosition
-- @param pegIndexOrName string/number 0 means the grob's pivot
-- @return number X position
-- @return number Y position
-- @return number Z position (virtual height)
--------------------------------------------------------------------------------
local function SubGrob__getPegPosition(self,pegIndexOrName)
	--[[ == Debug ==
		tabsPrint("SubGrob__getPegPosition() name:"..self.name);
		tabsIncrement();--]]
	local pegX, pegY, pegH = self:getPegOffset(pegIndexOrName);
	local posX, posY, posH = self:getPosition();
	--[[ == Debug ==
		tabsDecrement();
		tabsPrint("\tx:"..pegX+posX.." y:"..pegY+posY.." h:"..pegH+posH);--]]
	return pegX+posX, pegY+posY, pegH+posH;
end;

--------------------------------------------------------------------------------
-- Returns <x,y,h> peg's offset from the root grob's pivot
-- @class function
-- @name SubGrob:getPegRootOffset
-- @param pegIndexOrName string/number 0 means the grob's pivot
-- @return number X offset
-- @return number Y offset
-- @return number Z offset (virtual height)
--------------------------------------------------------------------------------
local function SubGrob__getPegRootOffset(self, pegIndexOrName)
	local pivotX, pivotY, pivotH = self.parentGrob:getPegRootOffset(self.pegIndex);
	local pegX, pegY, pegH = self:getPegOffset(pegIndexOrName);
	return pivotX+pegX, pivotY+pegY, pivotH+pegH;
end

--------------------------------------------------------------------------------
-- returns <x,y,w,h> the shade's map coordinates and size (in pixels).
-- @class function
-- @name SubGrob:getShade
-- @return number shade's X position
-- @return number shade's Y position
-- @return number shade's width
-- @return number shade's height
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Implementation of 'getShade' for single shade.
--------------------------------------------------------------------------------
local function SubGrob__getShade_SingleShade(self)
	local mapPosX, mapPosY = self:getPosition();
	return
		self.singleShade.x+mapPosX,
		self.singleShade.y+mapPosY,
		self.singleShade.w,
		self.singleShade.h;
end;

--------------------------------------------------------------------------------
-- Implementation of 'getShade' for multiple shades.
-------------------------------------------------------------------------------
local function SubGrob__getShade_ShadePerSprite(self)
	local mapPosX, mapPosY = self:getPosition();
	return
		self.shades[self.spriteIndex].x+mapPosX,
		self.shades[self.spriteIndex].y+mapPosY,
		self.shades[self.spriteIndex].w,
		self.shades[self.spriteIndex].h;
end;

--------------------------------------------------------------------------------
-- returns <x1, y1, x2, y2>, area which this grob visually occupies on the map (in pixels); Only considers one grob, even if it's the root; To get the complete area occupied by a grob hierarchy, use RootGrob__getFullImageArea()
-- @class function
-- @name Grob:getImageArea
-- @param none nil
-- @return number X1 (top border)
-- @return number Y1 (left border)
-- @return number X2 (bottom border)
-- @return number X2 (right border)
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- Implementation of 'Grob:getImageArea' for multiple image areas.
--------------------------------------------------------------------------------
local function SubGrob__getImageArea_AreaPerSprite(self)
	local mapPosX, mapPosY = self:getPosition();
	return
		mapPosX+self.imageAreas[self.spriteIndex].x1,
		mapPosY+self.imageAreas[self.spriteIndex].y1,
		mapPosX+self.imageAreas[self.spriteIndex].x2,
		mapPosY+self.imageAreas[self.spriteIndex].y2;
end;

--------------------------------------------------------------------------------
-- Implementation of 'Grob:getImageArea' for single image area.
--------------------------------------------------------------------------------
local function SubGrob__getImageArea_SingleArea(self)
	local mapPosX, mapPosY = self:getPosition();
	return
		mapPosX+self.singleImageArea.x1,
		mapPosY+self.singleImageArea.y1,
		mapPosX+self.singleImageArea.x2,
		mapPosY+self.singleImageArea.y2;
end;

--------------------------------------------------------------------------------
-- returns <x1, y1, x2, y2>, area which this grob hierarchy can eventually ocuppy, considering all posible angles of all grobs.
-- @class function
-- @name Grob:getMaxImageArea
-- @param none nil
-- @return number X1 (top border)
-- @return number Y1 (left border)
-- @return number X2 (bottom border)
-- @return number X2 (right border)
--------------------------------------------------------------------------------
local function SubGrob__getMaxImageArea_AreaPerSprite(self)
	local x1,y1,x2,y2 = 1000000,1000000,-1000000,-1000000;
	for index, area in ipairs(self.imageAreas)do
		x1 = (x1<area.x1) and x1 or area.x1;
		y1 = (y1<area.y1) and y1 or area.y1;
		x2 = (x2>area.x2) and x2 or area.x2;
		y2 = (y2>area.y2) and y2 or area.y2;
	end;
	return x1+self.x, y1+self.y, x2+self.x, y2+self.y;
end;

local SubGrob__getMaxImageArea_SingleArea
		= SubGrob__getImageArea_SingleArea;

--------------------------------------------------------------------------------
-- Attaches a child to sub grob.
-- @class function
-- @name SubGrob:attachChild
-- @param subGrob SubGrob The subgrob to attach
-- @param pegIndexOrName number/string The peg to attach the sub-grob to, counting from 1; Passing zero uses the grob's pivot as the peg (useful for shadows and ground-based effects).
-- @param drawPriority Grob's position in drawing order, counting from 1; 1 = highest priority (drawn first); 0 or nil = lowest priority (drawn last); Negative number means the grob won't be drawn (useful for shadows, which need to be drawn separately).
-- @return Grob The previous grob on the specified peg.
--------------------------------------------------------------------------------
local function SubGrob__attachChild(self, subGrob, pegIndexOrName, drawPriority)
	drawPriority = drawPriority or 0;
	--[[ == Debug ==
		print("SubGrob__attachChild()\n\tself:"..self.name.." subGrob:"..DBG_getGrobName(subGrob)
			.."\n\t pegIndexOrName:"..tostring(pegIndexOrName)
			.." drawPriority:"..tostring(drawPriority)..(drawPriority<0 and " [no notification]" or ""));
	--]]
	local oldGrob = Grob__attachChild(self, subGrob, pegIndexOrName);
	if drawPriority>=0 then
		self.parentGrob:childAdded(subGrob, drawPriority);
	end
	return oldGrob;
end;

--------------------------------------------------------------------------------
-- Callback; Recieves a notification from subgrob and if the child should be drawn, passes it on.
-- @class function
-- @name SubGrob:childAdded
-- @param grob Grob The added subgrob.
-- @param drawPriority number
--------------------------------------------------------------------------------
local function SubGrob__childAdded(self, grob, drawPriority)
	--[[ == Debug ==
	print("SubGrob__childAdded()\n\tself:"..self.name
		.." grob:"..DBG_getGrobName(grob)
		.."\n\t drawPriority:"..tostring(drawPriority)..(drawPriority<0 and " [not passed]" or ""));
	--]]
	if drawPriority>=0 then
		self.parentGrob:childAdded(grob, drawPriority);
	end
end;

--------------------------------------------------------------------------------
-- Removes a child grob
-- @class function
-- @name SubGrob:removeChild
-- @param grobReference Grob A pointer to the grob.
-- @return Grob The removed grob on success, or false if it wasn't found.
--------------------------------------------------------------------------------
local function SubGrob__removeChild(self, grobReference)
	if Grob__removeChild(self, grobReference)==false then
		return false;
	end;
	self.parentGrob:childRemoved(grobReference);
end;

--------------------------------------------------------------------------------
-- Callback to notify the root grob about removed sub-grob
-- @class function
-- @name SubGrob:childRemoved
-- @param grobReference Grob The removed subgrob.
--------------------------------------------------------------------------------
local function SubGrob__childRemoved(self, grobReference)
	self.parentGrob:childRemoved(grobReference);
end;

--------------------------------------------------------------------------------
-- Returns <x,y,h> grob's offset from the root grob
-- @class function
-- @name SubGrob:getOffset
-- @param none nil
-- @return number X offset
-- @return number Y offset
-- @return number Z offset (virtual height)
--------------------------------------------------------------------------------
local function SubGrob__getOffset(self)
	local x,y,h = self.parentGrob:getPegRootOffset(self.pegIndex);
	return x+self.displacementX, y+self.displacementY, h+self.displacementH;
end;

--------------------------------------------------------------------------------
-- Returns absolute map position of parent grob's peg this sub grob is mounted to.
-- @class function
-- @name SubGrob:getOffset
-- @param none nil
-- @return number X position
-- @return number Y position
-- @return number Z position (virtual height)
--------------------------------------------------------------------------------
local function SubGrob__getMountedPegPosition(self)
	return self.parentGrob:getPegPosition(self.pegIndex);
end

--------------------------------------------------------------------------------
-- Returns <x,y,h> the grob's map position (in pixels)
-- @class function
-- @name Grob:getPosition
-- @param none nil
-- @return number X position
-- @return number Y position
-- @return number Z position (virtual height)
--------------------------------------------------------------------------------
local function SubGrob__getPosition(self)
	--[[ == Debug ==
	tabsPrint("SubGrob__getPosition() name:"..self.name);
	tabsIncrement();
	--]]
	local x,y,h = self:getMountedPegPosition();
	--[[ == Debug ==
	tabsDecrement();
	tabsPrint("\tx:"..x.." y:"..y.." h:"..h);
	tabsPrint("\tDisplacement x:"..self.displacementX.." y:"..self.displacementY
		.." h:"..self.displacementH);
	--]]
	return x+self.displacementX, y+self.displacementY, h+self.displacementH;
end;

-- Getters and setters --
--------------------------------------------------------------------------------
-- Getter for 'synchronizeVisualAngle' attribute
-- @class function
-- @name SubGrob:getSynchronizeVisualAngle
-- @param none nil
-- @return boolean 'synchronizeVisualAngle' attribute value.
--------------------------------------------------------------------------------
local function SubGrob__getSynchronizeVisualAngle(self)
	return self.synchronizeVisualAngle;
end

--------------------------------------------------------------------------------
-- Sets whether visual angles should change in sync with parent grob.
-- @class function
-- @name SubGrob:setSynchronizeVisualAngle
-- @param value boolean
--------------------------------------------------------------------------------
local function SubGrob__setSynchronizeVisualAngle(self, value)
	self.synchronizeVisualAngle = value==true;
end

--------------------------------------------------------------------------------
-- Sets displacement between this SubGrob and the peg it's mounted to.
-- @class function
-- @name Grob:setDisplacement
-- @param x X axis offset
-- @param y X axis offset
-- @param z virtual Z axis offset
--------------------------------------------------------------------------------
local function SubGrob__setDisplacement(self,x,y,h)
	self.displacementX = x;
	self.displacementY = y;
	self.displacementH = h;
end

--------------------------------------------------------------------------------
-- Sets displacement between this SubGrob and the peg it's mounted to.
-- @class function
-- @name Grob:setDisplacement
-- @param none nil
-- @return number X offset
-- @return number Y offset
-- @return number Z offset (virtual height)
--------------------------------------------------------------------------------
local function SubGrob__getDisplacement(self)
	return self.displacementX, self.displacementY, self.displacementH;
end

--------------------------------------------------------------------------------
-- Sets the way this SubGrob reacts to it's parent rotation.
-- @class function
-- @name SubGrob:setAngleUpdateHandling
-- @param handling number One of ANGLE_UPDATE enum.
--------------------------------------------------------------------------------
local function SubGrob_setAngleUpdateHandling(self, handling)
	if
	handling ~= ANGLE_UPDATE_FOLLOW
		and handling~=ANGLE_UPDATE_IGNORE and handling~=ANGLE_UPDATE_SKIP
	then
		error("<BDT_Grob:SubGrob:setAngleUpdateHandling>: Invalid argument");
	end
	self.angleUpdateHandling = handling;
end

--------------------------------------------------------------------------------
-- Gets the way this SubGrob reacts to it's parent rotation.
-- @class function
-- @name SubGrob:setAngleUpdateHandling
-- @param none nil
-- @return number One of ANGLE_UPDATE enum.
--------------------------------------------------------------------------------
local function SubGrob__getAngleUpdateHandling(self)
	return self.angleUpdateHandling;
end

local function SubGrob__draw(self, screenX, screenY)
	--[[ == Debug ==
	tabsPrint("SubGrob__draw() name:"..self.name);--]]
	--[[tabsPrint("\tvisAngle:"..self.spriteIndex.." x:"..screenX.." y:"..screenY);
	--]]
	--OLD love.graphics.draw( self.sprites[self.spriteIndex], screenX, screenY );
	local s = self.sprites[self.spriteIndex]
	love.graphics.draw(s.image, s.x+screenX, s.y+screenY);
end



--[[ ============= Deprecated ===========================
local function RootGrob__attachLinkedGrob(self, g)
	table.insert(self.linkedGrobs, g);
end;


local function RootGrob__removeLinkedGrob(self, g)
	BDT.tableRemoveByValue(self.linkedGrobs, g);
end;
-- ====================================================== --]]

local BDT_GROB = {};
BDT_GROB.ANGLE_UPDATE_FOLLOW = ANGLE_UPDATE_FOLLOW;
BDT_GROB.ANGLE_UPDATE_IGNORE = ANGLE_UPDATE_IGNORE;
BDT_GROB.ANGLE_UPDATE_SKIP = ANGLE_UPDATE_SKIP;

--------------------------------------------------------------------------------
-- @class table
-- @name class Workshop
-- @description Workshop is a factory object for building grobs
-- @field imagesToLoad Table{ [: {x,y,path} :] }; List of images to load; Needed for partial loading; Only not loaded images are listed, loaded are deleted.
-- @field grobDir String; Directory to load images from
--------------------------------------------------------------------------------
local Workshop = {};
Workshop.__index = Workshop;

--------------------------------------------------------------------------------
-- Builds a basic grob
-- @return Grob
--------------------------------------------------------------------------------
function Workshop:buildGrob()
	-- Pre-allocate the "children" table (to make ipairs work)
	local children = {};
	local childrenSize = self.protoGrob.pegs and #self.protoGrob.pegs+1 or 1;
	for i = 1,childrenSize,1 do
		table.insert(children, false);
	end
	-- Create the grob
	local grob = {
		spriteIndex = 1,
		angle = 0,
		children = children
	};
	return grob;
end

--------------------------------------------------------------------------------
-- Builds a root grob; Root grobs forms a base of grob hierarchy; Can be positioned directly.
-- @param x Initial X position.
-- @param y Initial Y position.
-- @param h Initial position - virtual height.
-- @return RootGrob
--------------------------------------------------------------------------------
function Workshop:buildRoot( x,y,h )
	if self.imagesToLoad and #self.imagesToLoad>0 then
		error("BDT_Grob.Workshop:buildRoot() Can't build grob,"
			.."there are "..#self.imagesToLoad.." images left to load.");
	end
	checkArg("Workshop:buildRoot", x, 1, "number");
	checkArg("Workshop:buildRoot", y, 2, "number");
	checkArg("Workshop:buildRoot", h, 3, "number");

	local grob = setmetatable(self:buildGrob(),self.protoRoot);
	grob.x = x;
	grob.y = y;
	grob.h = h;
	--[[ == Debug ==
		print("<Workshop:buildRoot>"
		.."grob.pos:\n"..tableToString(grob.pos)
		.."len:"..#grob.pos.."x,y:",x,y);--]]
	--[[ == Debug ==
		print("<Workshop:buildRoot>"
		.."grob.singleShade:\n"..tableToString(grob.singleShade)
		.."\nprotogrob singleshade:\n"..tableToString(self.protoGrob.singleShade));--]]
	--[[ == Debug ==
		print("buildRoot: noAngles:",grob.noAngles);--]]
	local shadeX, shadeY, shadeW, shadeH = grob:getShade();
	grob.z = shadeY+shadeH;
	grob.zMod=0;
	grob.drawingOrder = {grob};
	grob.angleUpdateHandling = ANGLE_UPDATE_FOLLOW;
	return grob;
end;

--------------------------------------------------------------------------------
-- Builds a sub grob; SubGrobs are made to be mounted into a grob hierarchy; Cannot be positioned directly.
-- @return SubGrob
--------------------------------------------------------------------------------
function Workshop:buildSub()
	if self.imagesToLoad and #self.imagesToLoad>0 then
		error("<Workshop:buildRoot>: Can't build grob,"
			.."there are "..#self.imagesToLoad.." images left to load.");
	end

	local grob = self:buildGrob();

	grob.parentGrob = 0;
	grob.pegIndex = -1;
	grob.angleUpdateHandling = ANGLE_UPDATE_FOLLOW
	grob.synchronizeVisualAngle = false
	grob.angleSyncData = 0
	grob.angleInSync = false
	grob.displacementX=0
	grob.displacementY=0
	grob.displacementH=0

	return setmetatable(grob,self.protoSub);
end;

-- -- Workshop partial loading -- --

--------------------------------------------------------------------------------
-- Load next image.
-- @return boolean true on success, or false if there is nothing more to load.
--------------------------------------------------------------------------------
function Workshop:loadNextImage()
	if self.imagesToLoad and #self.imagesToLoad>0 then
		local spriteDef = table.remove(self.imagesToLoad, 1);
		local pic = love.graphics.newImage(self.grobDir..spriteDef.path);
		pic:setCenter( -spriteDef.x, -spriteDef.y );
		table.insert(self.protoGrob.sprites, pic);
		return true;
	else
		return false;
	end
end

--------------------------------------------------------------------------------
-- Returns the path of the next image to be loaded
-- @return string Image path or empty string if there's nothing more to load.
--------------------------------------------------------------------------------
function Workshop:getNextImagePath()
	if self.imagesToLoad and #self.imagesToLoad>0 then
		return self.imagesToLoad[1].path;
	end
end

--------------------------------------------------------------------------------
-- Returns the number of images to load
-- @return number Number of images to load
--------------------------------------------------------------------------------
function Workshop:getNoImagesToLoad()
	if self.imagesToLoad then
		return #self.imagesToLoad;
	else
		return 0;
	end
end

local grobfileNamesToTry={
	"grobfile.lua",
	"Grobfile.lua",
	"grob.lua",
	"Grob.lua"
}

return function(BDT_Grob_Dir) -- Module init function

--------------------------------------------------------------------------------
-- Creates a new Workshop (factory for grobs)
-- @param dir string Directory to load grob from (without slash)
-- @param grobfileName string The name of grobfile.
-- @param partialLoading boolean Enables loading images one by one using the loadNextImage method. Default false.
-- @return Workshop
--------------------------------------------------------------------------------
function BDT_GROB.newWorkshop(dir, grobfileName, partialLoading)
	local errMsg = "ERROR BDT_GROB.newWorkshop():";
	local newGrobSprite = require(BDT_Grob_Dir.."/BDT_Grob_Sprite.lua")(BDT_Grob_Dir);
	-- Load the script --
	-- Check the path was entered
	if not dir or dir=="" then
		error(errMsg.." No directory entered");
	else
		-- Check end slash
		local slash = string.sub(dir, string.len(dir)-1);
		if slash~="/" and slash~="\\" then
			dir = dir.."/";
		end
	end
	local grobfilePath;
	local grobfileFound=false;
	if not grobfileName or not love.filesystem.exists(dir..'/'..grobfileName) then
		local love_filesystem_exists = love.filesystem.exists;
		-- Look for grobfile
		for i,n in ipairs(grobfileNamesToTry) do
			grobfilePath = dir..'/'..n;
			if love_filesystem_exists(grobfilePath) then
				grobfileFound=true;
				break;
			end
		end
		if not grobfileFound then
			error(errMsg.." No grobfile found in '"..dir.."'");
		end
	end
	-- Parses the file to a function
	local readDefFile = love.filesystem.load(grobfilePath);
	local def = {};
	setfenv(readDefFile, def);
	readDefFile();

	-- Create prototypes --
	-- Metatable for all grobs
	local ProtoGrob = {
		-- Peg manipulation
		getPeg = Grob__getPeg;
		getPegIndex = Grob__getPegIndex;
		getPegCount = Grob__getPegCount;
		getPegOffset = Grob__getPegOffset;
		-- Angle manipulation
		setAngleDegrees = Grob__setAngleDegrees;
		setAngleRadians = Grob__setAngleRadians;
		getAngleDegrees = Grob__getAngleDegrees;
		getAngleRadians = Grob__getAngleRadians;
		getVisualAngleDegrees = Grob__getVisualAngleDegrees;
		getVisualAngleRadians = Grob__getVisualAngleRadians;
		rotateDegrees = Grob__rotateDegrees;
		rotateRadians = Grob__rotateRadians;
		getVisualAngleIndex = Grob__getVisualAngleIndex;
		-- Drawing
		drawPoints = Grob__drawPoints;
	}
	ProtoGrob.__index = ProtoGrob;
	ProtoGrob.name = def.Name;

	-- Metatable for root grobs
	local ProtoRoot = setmetatable({
		-- Peg manipulations
		getPegPosition = RootGrob__getPegPosition;
		getPegRootOffset = RootGrob__getPegRootOffset;

		getFullImageArea = RootGrob__getFullImageArea;
		attachChild = RootGrob__attachChild;
		childAdded = RootGrob__childAdded;
		removeChild = RootGrob__removeChild;
		childRemoved = RootGrob__childRemoved;
		setAngleDegrees = RootGrob__setAngleDegrees;
		setAngleRadians = RootGrob__setAngleRadians;
		setPosition = RootGrob__setMapPos;
		draw = RootGrob__draw;
		getOffset = RootGrob__getOffset;
		updateZ = RootGrob__updateZ;
		getPosition = RootGrob__getPosition;
	},ProtoGrob);
	ProtoRoot.__index = ProtoRoot;

	-- Metatable for sub grobs
	local ProtoSub = setmetatable({
		-- Peg manipulations
		getPegPosition = SubGrob__getPegPosition;
		getPegRootOffset = SubGrob__getPegRootOffset;
		getMountedPegPosition = SubGrob__getMountedPegPosition;

		attachChild = SubGrob__attachChild;
		childAdded = SubGrob__childAdded;
		removeChild = SubGrob__removeChild;
		childRemoved = SubGrob__childRemoved;
		getOffset = SubGrob__getOffset;
		getPosition = SubGrob__getPosition;
		getPegPosition = SubGrob__getPegPosition;
		parentRotated = SubGrob__parentRotated;
		setSynchronizeVisualAngle = SubGrob__setSynchronizeVisualAngle;
		getSynchronizeVisualAngle = SubGrob__getSynchronizeVisualAngle;
		getAngleUpdateHandling = SubGrob__getAngleUpdateHandling;
		setAngleUpdateHandling = SubGrob__setAngleUpdateHandling;
		getDisplacement = SubGrob__getDisplacement,
		setDisplacement = SubGrob__setDisplacement,
		-- Drawing
		draw = SubGrob__draw;
	},ProtoGrob);
	ProtoSub.__index = ProtoSub;

	-- Handle number of angles
	ProtoGrob.noAngles = def.NoVisualAngles;

	-- Handle image areas
	if not def.ImageAreas then
		error(errMsg.." Image area not defined in "..path);
	end
	if #def.ImageAreas==1 then
		ProtoGrob.singleImageArea = def.ImageAreas[1]
		ProtoSub.getImageArea = SubGrob__getImageArea_SingleArea;
		ProtoRoot.getImageArea = RootGrob__getImageArea_SingleArea;
	else
		ProtoGrob.imageAreas = def.ImageAreas;
		ProtoSub.getImageArea = SubGrob__getImageArea_AreaPerSprite;
		ProtoRoot.getImageArea = RootGrob__getImageArea_AreaPerSprite;
	end

	-- Handle pegs
	ProtoGrob.pegs = def.Pegs;

	-- Handle shades
	if def.Shades then
		if #def.Shades==1 then
			ProtoGrob.singleShade = def.Shades[1]
			ProtoRoot.getShade = RootGrob__getShade_SingleShade;
			ProtoSub.getShade = SubGrob__getShade_SingleShade;
		else
			ProtoGrob.shades = def.Shades;
			ProtoRoot.getShade = RootGrob__getShade_ShadePerSprite;
			ProtoSub.getShade = SubGrob__getShade_ShadePerSprite;
		end;
	else
		ProtoRoot.getShade = RootGrob__getShade_NoShade;
		ProtoSub.getShade = SubGrob__getShade_NoShade;
	end
	-- else error("<GROB::newWorkshop> Shade(s) not defined in "..path);

	-- Load sprite(s)
	if(def.Sprites == nil) then
		error(errMsg.." Sprite(s) not defined in "..path);
	end;
	ProtoGrob.sprites = {};
	-- If partial loading is disabled, load sprites now.
	local imagesToLoad;
	if not partialLoading then
		for index,spriteDef in ipairs(def.Sprites) do
			local pic = love.graphics.newImage(dir..spriteDef.path);
			if(pic==nil) then
				error(errMsg.." Failed to load sprite "..spritePath);
			end;
			--OLD pic:setCenter(-spriteDef.x, -spriteDef.y);
			local sprite = newGrobSprite(pic,spriteDef.x,spriteDef.y);
			--print("DBG BDT_Grob.newWorkshop sprite:"..tostring(sprite)
			--	..", newGrobSprite:"..tostring(newGrobSprite));
			table.insert(ProtoGrob.sprites,sprite);
		end
	else
		imagesToLoad = def.Sprites;
	end

	-- Return the new workshop
	return setmetatable({
		protoGrob = ProtoGrob;
		protoRoot = ProtoRoot;
		protoSub = ProtoSub;
		imagesToLoad = imagesToLoad;
		grobDir = dir;
	},
	Workshop);

end;

--------------------------------------------------------------------------------
-- An implementation of the sorting function, using insert-sort algorithm.
-- @param t table Table of grobs.
--------------------------------------------------------------------------------
function BDT_GROB.zInsertSort( t )
	local allSorted = false;
	while not allSorted do
		local thisPassSorted = true;
		local lastCheckedGrobZ = -10000;
		-- Iterate the table to find misplaced grobs
		for indexToCheck, grobToCheck in ipairs(t) do
			--[[
			console:printLn("|Z-Sort| zMod:"..grobToCheck.zMod);
			--]]
			-- If two grobs have the same z, increase zMod for one of them
			if(grobToCheck.z==lastCheckedGrobZ)then
				grobToCheck.zMod= grobToCheck.zMod+0.000000001;
				grobToCheck.z=grobToCheck.z+grobToCheck.zMod;
			end;
			if(grobToCheck.z<lastCheckedGrobZ) then
				lastCheckedGrobZ = grobToCheck.z;
				thisPassSorted = false;
				table.remove(t,indexToCheck);
				-- Find the index to place the grob
				local frontZ = -10000000;
				local rearZ = 0;
				for visIndex, visGrob in ipairs(t) do
					rearZ = frontZ;
					frontZ = visGrob.z;
					if( grobToCheck.z>=rearZ and grobToCheck.z<=frontZ ) then
						table.insert( t, visIndex, grobToCheck );

						grobToCheck=nil;
						break;
					end;
				end;
				-- If the grob wasn't inserted, put it in the front
				if(grobToCheck) then
					table.insert(t, grobToCheck);

				end;
			else
				lastCheckedGrobZ = grobToCheck.z;
			end;
		end;
		allSorted = thisPassSorted;
	end;
end;

--------------------------------------------------------------------------------
-- Sorts a table of grobs based on their z-index.
-- @param t table Table of grobs.
--------------------------------------------------------------------------------
BDT_GROB.zSort = BDT_GROB.zInsertSort;

--------------------------------------------------------------------------------
-- Prints children of the supplied grob; Debug utility.
-- @param grob Grob
--------------------------------------------------------------------------------
function BDT_GROB.printGrobChildren(grob)
	print("<Grob's children> ("..grob.name..") #:"..#grob.children);
	for i, g in ipairs(grob.children) do
		if g then
			print("\t "..i..": "..g.name);
		end
	end
end

	return BDT_GROB;
end
