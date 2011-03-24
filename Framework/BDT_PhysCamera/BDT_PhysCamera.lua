-- PhysCamera
-- It displays the love.physics world and its contents

--[[
== PhysCamera ==
Methods:
	+ zoomIn( volume )
	+ zoomOut( volume )
	+ zoom( volumeChange )
	- drawPolys( shapeList, outlineColor, fillColor )
	- drawCircles( shapeList, outlineColor, fillColor )
	+ drawOutline(  )
	+ xWorldPointsToScreen(...)
	+ yWorldPointsToScreen(...)
	+ xyWorldPointsToScreen(...)
	- drawMouseJoint(mouseJoint)
	+ draw( shapeList, lineColor)
	+ getZoom()
	+ moveOnWorld( pixelsX, pixelsY )
	+ computeWorldPos(screenX, screenY)
	+ getBodiesOnPoint(worldX, worldY)

zoomVolume:
	1 = objects are of the same size as in 2d graphics

shapesTable (it must contain following):
	staticPolys
	staticCircles
	movingPolys
	movingCircles
	borderPolys
	sensorPolys
	sensorCircles

NOTE: shapes must have attached shape-data table with a 'body' attribute,
	pointing to their parent body.

--]]

local function DBG_printTable(t)
	if(type(t) ~= "table") then
		error("DBG_printTable(): not a table, but "..tostring(t));
	end
	print("#"..#t);
	for k,v in pairs(t) do
		print("\t"..k..": "..type(v).." "..tostring(v));
	end
end

return function ( BDT ) -- Enclosing function

local PhysCamera = {};
PhysCamera.__index = PhysCamera;

--------------------------------------------------------------------------------
-- Enclosing function; Needed to pass init params to the module.
-- @param viewportSheet BDT_GUI.Sheet
-- @param shapesTable Table (See source doc)
-- @return BDT_GUI module
--------------------------------------------------------------------------------
local function newPhysCamera(
		_maxZoom, _minZoom, _zoomStep, _initialZoom,
		_worldPosVec,
		viewportSheet,
		shapesTable,
		_converter,
		_mouseJointHolder)
	if( type(_converter) ~= "table") then
		error("BDT_PhysCamera.newPysCamera(): invalid value for _converter parameter: "..tostring(_converter));
	end;
	local fillAlpha = 50;
	return setmetatable(
	{
		maxZoom = _maxZoom,
		minZoom = _minZoom,
		zoomStep = _zoomStep,
		zoomVolume = _initialZoom,
		-- World position of the viewport's center, in B2Meters
		-- Since 0.7.0 : in pixels.
		worldPos = _worldPosVec;
		viewport = viewportSheet;
		shapes = shapesTable;
		converter = _converter;
		mouseJointHolder = _mouseJointHolder;

		colors = {
			staticShapesOutline = { 0,255,0,255 };
			staticShapesFill = { 0,255,0,fillAlpha };
			borderShapesOutline = {160,90,160,255};
			borderShapesFill = {160,90,160,fillAlpha};
			movingShapesOutline = {255,255,255,255};
			movingShapesFill = {255,255,255,fillAlpha};
			sensorShapesOutline = {255,255,0,255};
			sensorShapesFill = {255,255,0,fillAlpha};
			mouseJoint = {0,255,255,255};
			viewportOutlineColor = {0,0,255,255};
			background = {50,50,50,100};
		};
	},
	PhysCamera
	);
end;

function PhysCamera:zoomIn( volume )
	--print("<physcam:zoomin>");
	volume = volume or 1;
	if self.zoomVolume < self.maxZoom then
		self.zoomVolume = self.zoomVolume + volume*self.zoomStep;
		if( self.zoomVolume>self.maxZoom ) then
			self.zoomVolume=self.maxZoom;
		end;
	end;
end;

function PhysCamera:zoomOut( volume )
	--print("<physcam:zoomout>");
	volume = volume or 1;
	if( self.zoomVolume > self.minZoom ) then
		self.zoomVolume = self.zoomVolume - volume*self.zoomStep;
		if( self.zoomVolume<self.minZoom ) then
			self.zoomVolume=self.minZoom;
		end;
	end
end;

function PhysCamera:zoom( volumeChange )
	if( volumeChange>0 ) then
		self:zoomIn(volumeChange);
	elseif( volumeChange<0 ) then
		self:zoomOut( -volumeChange );
	end;
end;

function PhysCamera:_OLD_drawPolys( shapeList, outlineColor, fillColor )

	--local origColor = love.graphics.getColor();
	--if(lineColor~=nil) then love.graphics.setColor(lineColor) end;
	local shapeCount=0; --debug variable

	for name, shape in pairs(shapeList) do
		-- save shape's vertices in a table
		local vertices = {shape:getPoints()};
		local i;
		local iMax = #vertices-1;
		for i=1, iMax, 2 do

			--[[ old converter methods
			vertices[i] =
				(self.viewport.absolutePos.x+(self.viewport.w/2)) +
					((vertices[i]-self.worldPos.x)*BDT.PIXELS_IN_B2METER)
						*self.zoomVolume;
			vertices[i+1] =
				(self.viewport.absolutePos.y+self.viewport.h/2) +
					((vertices[i+1]-self.worldPos.y)*BDT.PIXELS_IN_B2METER)
						*self.zoomVolume;
			-- end of old conversions]]

			vertices[i] =
				(self.viewport.absolutePos.x+(self.viewport.w/2)) +
				self.converter:b2MetersToPixels(vertices[i]-self.worldPos.x)
				*self.zoomVolume;
			vertices[i+1] =
				(self.viewport.absolutePos.y+self.viewport.h/2) +
				self.converter:b2MetersToPixels(vertices[i+1]-self.worldPos.y)
				*self.zoomVolume;

		end;
		love.graphics.setColor(fillColor);
		love.graphics.polygon( love.draw_fill, vertices );
		love.graphics.setColor(outlineColor);
		love.graphics.polygon( love.draw_line, vertices );
		shapeCount = shapeCount+1;
	end;
	return shapeCount; --Debug
	--love.graphics.setColor( origColor );
	--game.display.console:printLn("phys view: "..shapeCount.." shapes");
end;

function PhysCamera:drawPolys(shapeList, outlineColor, fillColor)
	-- Optimization
	local love_graphics = love.graphics;
	local love_graphics_setColor = love_graphics.setColor;
	local love_graphics_polygon = love_graphics.polygon;
	-- Viewport screen position
	local vpCenterX = self.viewport.h/2 + self.viewport.absolutePos.x;
	local vpCenterY = self.viewport.w/2 + self.viewport.absolutePos.y;
	-- Camera's center world position
	local camX, camY = self.worldPos.x, self.worldPos.y;

	for name, shape in pairs(shapeList) do
		local vertices = {shape:getPoints()}
		local i;
		local iMax = #vertices - 1; -- Vertices are x,y pairs
		for i = 1, iMax, 2 do
			vertices[i] = vpCenterX + (vertices[i] - camX) * self.zoomVolume;
			vertices[i + 1] = vpCenterY + (vertices[i + 1] - camY) * self.zoomVolume;
		end
		love_graphics_setColor(fillColor);
		love_graphics_polygon("fill", vertices);
		love_graphics_setColor(outlineColor);
		love_graphics_polygon("line", vertices);
	end
end

function PhysCamera:_OLD__drawCircles( shapeList, outlineColor, fillColor )
	local DBG_shapeCount = 0;
	--console:printLn("<phys cam> circles:"..#shapeList);
	for index,circle in pairs(shapeList) do

		local circleData = circle:getData();
		local radius = (circle:getRadius()/self.converter.b2MetersInPixel)*self.zoomVolume;
		local mapX, mapY = circleData:getPosition();
		local x = (((mapX-self.worldPos.x)/self.converter.b2MetersInPixel)*self.zoomVolume)
				+self.viewport.absolutePos.x+self.viewport.w/2;
		local y = (((mapY-self.worldPos.y)/self.converter.b2MetersInPixel)*self.zoomVolume)
				+self.viewport.absolutePos.y+self.viewport.h/2;
		love.graphics.setColor( fillColor );
		love.graphics.circle( love.draw_fill, x, y, radius );
		love.graphics.setColor( outlineColor );
		love.graphics.circle( love.draw_line, x, y, radius );
		--console:printLn("<physCam circle> x:"..x.." y:"..y.." radius:"..radius);
	end;
	return DBG_shapeCount;
end;

function PhysCamera:drawCircles(shapeList, outlineColor, fillColor)
	-- Optimization
	local love_graphics = love.graphics;
	local love_graphics_setColor = love_graphics.setColor;
	local love_graphics_circle = love_graphics.circle;
	-- Viewport screen position
	local vpCenterX = self.viewport.h/2 + self.viewport.absolutePos.x;
	local vpCenterY = self.viewport.w/2 + self.viewport.absolutePos.y;
	-- Camera's center world position
	local camX, camY = self.worldPos.x, self.worldPos.y;

	for name, circle in pairs(shapeList) do
		local radius = circle:getRadius() * self.zoomVolume;
		-- Circle map pos
		local mapX, mapY = circle:getData():getPosition();
		-- Circle screen pos
		local x = (mapX - camX) * self.zoomVolume + vpCenterX;
		local y = (mapY - camY) * self.zoomVolume + vpCenterY;
		love_graphics_setColor(fillColor);
		love_graphics_circle("fill", x, y, radius);
		love_graphics_setColor(outlineColor);
		love_graphics_circle("line", x, y, radius);
	end
end

function PhysCamera:drawOutline(  )
	love.graphics.setColor( self.colors.viewportOutlineColor );
	love.graphics.rectangle( "line",
		self.viewport.absolutePos.x, self.viewport.absolutePos.y,
		self.viewport.w, self.viewport.h );
end;

function PhysCamera:xWorldPointsToScreen(...)
	-- viewport screen center
	local vpCenterX = self.viewport.absolutePos.x+self.viewport.w/2;

	local points = {...};
	points = (type(points[1])=="table") and points[1] or points;
	for index, point in ipairs(points[1]) do
		points[index] = (self.converter.b2MetersToPixels(point-self.worldPos.x)
					*self.zoomVolume)
						+vpCenterX;
	end;
	return unpack(points);
end;

function PhysCamera:yWorldPointsToScreen(...)
	-- viewport screen center
	local vpCenterY = self.viewport.absolutePos.y+self.viewport.h/2;

	local points = {...};
	points = (type(points[1])=="table") and points[1] or points;
	for index, point in ipairs(points[1]) do
		points[index] = (self.converter.b2MetersToPixels(point-self.worldPos.y)
					*self.zoomVolume)
						+vpCenterY;
	end;
	return unpack(points);
end;

function PhysCamera:xyWorldPointsToScreen(...)
	-- viewport center screen coordinates
	local vpCenterX, vpCenterY =
		self.viewport.absolutePos.x+self.viewport.w/2,
		self.viewport.absolutePos.y+self.viewport.h/2;

	local points = {...};
	points = (type(points[1])=="table") and points[1] or points;
	for i=1,#points,2 do
		--[[
		print("<PhysCamera:xyWorldPointsToScreen>",
			"points[i],points[i+1],self.worldPos.x,self.worldPos.y,self.zoomVolume,vpCenterX,vpCenterY",
			points[i],points[i+1],self.worldPos.x,self.worldPos.y,self.zoomVolume,vpCenterX,vpCenterY);
		--]]
		points[i],points[i+1]=
			-- x coordinate
			self.converter:b2MetersToPixels(points[i]-self.worldPos.x)
				*self.zoomVolume
						+vpCenterX,
			-- y coordinate
			(self.converter:b2MetersToPixels(points[i+1]-self.worldPos.y)
					*self.zoomVolume)
						+vpCenterY;
	end;
	return unpack(points);
end;

function PhysCamera:drawMouseJoint(mouseJoint)
	-- viewport center screen coordinates
	local vpCenterX, vpCenterY =
		self.viewport.absolutePos.x+self.viewport.w/2,
		self.viewport.absolutePos.y+self.viewport.h/2;

	love.graphics.setColor( self.colors.mouseJoint );
	local x1,y1,x2,y2 = self:xyWorldPointsToScreen(mouseJoint:getAnchors());
	love.graphics.line(x1,y1,x2,y2);
	love.graphics.setPointSize(2);
	love.graphics.point(x1,y1);
	love.graphics.point(x2,y2);
end;

function PhysCamera:draw()
	local love_graphics = love.graphics;
	local shapes = self.shapes;
	local colors = self.colors;
	-- Viewport screen position
	local wpX, wpY = self.viewport.absolutePos.x, self.viewport.absolutePos.y;
	local wpW, wpH = self.viewport.w, self.viewport.h;

	-- Save enviroment
	local origColorR, origColorG, origColorB, origColorA = love_graphics.getColor();
	local origScissorX, origScissorY, origScissorW, origScissorH = love_graphics.getScissor();

	--[[print("PhysCamera:draw() viewport: ",self.viewport.absolutePos.x, self.viewport.absolutePos.y,
		self.viewport.w, self.viewport.h, "orig.scissor:", origScissor);--]]
	love_graphics.setScissor(wpX, wpY, wpW, wpH);

	-- Background
	love_graphics.setColor( self.colors.background );
	love_graphics.rectangle( "fill", wpX, wpY, wpW, wpH );

	-- Border shapes
	self:drawPolys(
			shapes.borderPolys,
			colors.borderShapesOutline,
			colors.borderShapesFill);

	-- Static shapes
	self:drawPolys(
			shapes.staticPolys,
			colors.staticShapesOutline,
			colors.staticShapesFill);
	self:drawCircles(
			shapes.staticCircles,
			colors.staticShapesOutline,
			colors.staticShapesFill);

	-- Moving shapes
	self:drawPolys(
			shapes.movingPolys,
			colors.movingShapesOutline,
			colors.movingShapesFill);
	self:drawCircles(
			shapes.movingCircles,
			colors.movingShapesOutline,
			colors.movingShapesFill);

	-- Sensor shapes
	self:drawPolys(
			shapes.sensorPolys,
			colors.sensorShapesOutline,
			colors.sensorShapesOutline);
	self:drawCircles(
			shapes.sensorCircles,
			colors.sensorShapesOutline,
			colors.sensorShapesOutline);

	-- Mouse joint
	if(self.mouseJointHolder.joint)then
		self:drawMouseJoint(self.mouseJointHolder.joint);
	end;

	self:drawOutline();

	-- Restore enviroment
	love_graphics.setColor( origColorR, origColorG, origColorB, origColorA );
	if origScissor then
		love_graphics.setScissor(origScissorX, origScissorY, origScissorW, origScissorH);
	else
		love_graphics.setScissor();
	end;
end;

function PhysCamera:getZoom()
	return self.zoomVolume;
end;

function PhysCamera:moveOnWorld( pixelsX, pixelsY )
	--[[ old conversions
	self.worldPos.x = self.worldPos.x +
		pixelsX*(BDT.B2METERS_IN_PIXEL/self.zoomVolume);
	self.worldPos.y = self.worldPos.y +
		pixelsY*(BDT.B2METERS_IN_PIXEL/self.zoomVolume);
	--]]
	self.worldPos.x = self.worldPos.x +
		pixelsX*(self.converter.b2MetersInPixel/self.zoomVolume);
	self.worldPos.y = self.worldPos.y +
		pixelsY*(self.converter.b2MetersInPixel/self.zoomVolume);
end;

--- Computes world coordinates from screen coordinates
function PhysCamera:computeWorldPos(screenX, screenY)
	return
		--[[ old conversions
		self.worldPos.x
			+(((screenX - (self.viewport.absolutePos.x+self.viewport.w/2))
				*BDT.B2METERS_IN_PIXEL)
					/self.zoomVolume),
		self.worldPos.y
			+(((screenY - (self.viewport.absolutePos.y+self.viewport.h/2))
				*BDT.B2METERS_IN_PIXEL)
					/self.zoomVolume);
		--]]
		self.worldPos.x
			+(((screenX - (self.viewport.absolutePos.x+self.viewport.w/2))
				*self.converter.b2MetersInPixel)
					/self.zoomVolume),
		self.worldPos.y
			+(((screenY - (self.viewport.absolutePos.y+self.viewport.h/2))
				*self.converter.b2MetersInPixel)
					/self.zoomVolume);


end;

--- Returns all bodies touching the entered point
-- Note: only works with shapes with explicitly their body pointer in shape-data
-- @param worldX Tested point x coordinate (in b2Meters)
-- @param worldY Tested point y coordinate (in b2Meters)
function PhysCamera:getBodiesOnPoint(worldX, worldY)
	local bodies = {};
	local prisms = 0;

	for index, shape in ipairs(self.shapes.movingPolys) do
		if( shape:getData().body ) then
			prisms = prisms+1;
			if( shape:testPoint(worldX,worldY) ) then
				table.insert(bodies,shape:getData().body);
			end;
		end;
	end;
	--console:printLn("<phys cam: get bodies> ok prisms:",prisms);
	for index,circle in ipairs(self.shapes.movingCircles) do
		if (circle:getData().body) then
			if( circle:testPoint(worldX,worldY) ) then
				table.insert(bodies,circle:getData().body);
			end;
		end;
	end;

	return unpack(bodies);
end;

return {
	newPhysCamera = newPhysCamera;
}

end; -- End of enclosing function

