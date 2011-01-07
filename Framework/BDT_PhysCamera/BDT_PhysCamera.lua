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

return function ( battledale ) -- Enclosing function

local PhysCamera = {};
PhysCamera.__index = PhysCamera;

local function newPhysCamera(
		_maxZoom, _minZoom, _zoomStep, _initialZoom,
		_worldPosVec,
		_viewportRectangle,
		_shapeTable, _converter, _mouseJointHolder)
	if( type(_converter) ~= "table") then
		error("battledale.newPysCamera(): invalid value for _converter parameter: "..tostring(_converter));
	end;	
	local fillAlpha = 50;
	return setmetatable(
	{
		maxZoom = _maxZoom,
		minZoom = _minZoom,
		zoomStep = _zoomStep,
		zoomVolume = _initialZoom,
		-- World position of the viewport's center, in B2Meters
		worldPos = _worldPosVec;
		viewport = _viewportRectangle;
		shapes = _shapeTable;
		converter = _converter;
		mouseJointHolder = _mouseJointHolder;
		print("<phys cam constructor> #shapeTable.borderPolys", #_shapeTable.borderPolys);
		colors = {
			staticShapesOutline = love.graphics.newColor( 0,255,0,255 );
			staticShapesFill = love.graphics.newColor( 0,255,0,fillAlpha );
			borderShapesOutline = love.graphics.newColor(160,90,160,255);
			borderShapesFill = love.graphics.newColor(160,90,160,fillAlpha);
			movingShapesOutline = love.graphics.newColor(255,255,255,255);
			movingShapesFill = love.graphics.newColor(255,255,255,fillAlpha);
			sensorShapesOutline = love.graphics.newColor(255,255,0,255);
			sensorShapesFill = love.graphics.newColor(255,255,0,fillAlpha);
			mouseJoint = love.graphics.newColor(0,255,255,255);
			viewportOutlineColor = love.graphics.newColor(0,0,255,255);
			background = love.graphics.newColor(50,50,50,100);
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

function PhysCamera:drawPolys( shapeList, outlineColor, fillColor )
			
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
					((vertices[i]-self.worldPos.x)*battledale.PIXELS_IN_B2METER)
						*self.zoomVolume;
			vertices[i+1] = 
				(self.viewport.absolutePos.y+self.viewport.h/2) + 
					((vertices[i+1]-self.worldPos.y)*battledale.PIXELS_IN_B2METER)
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

function PhysCamera:drawCircles( shapeList, outlineColor, fillColor )
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
		
function PhysCamera:drawOutline(  )
	love.graphics.setColor( self.colors.viewportOutlineColor );
	love.graphics.rectangle( love.draw_line, 
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

function PhysCamera:draw( shapeList, lineColor)
	-- Save enviroment
	local origColor = love.graphics.getColor();
	local origScissor = love.graphics.getScissor();
	local shapeCount = 0; -- Debug
	
	--print("<phys cam:draw> viewport: ",self.viewport.absolutePos.x, self.viewport.absolutePos.y, 
		--self.viewport.w, self.viewport.h, "orig.scissor:", origScissor);
	love.graphics.setScissor( 
		self.viewport.absolutePos.x, self.viewport.absolutePos.y, 
		self.viewport.w, self.viewport.h );
		
	-- Background
	love.graphics.setColor( self.colors.background );
	love.graphics.rectangle( love.draw_fill, 
		self.viewport.absolutePos.x, self.viewport.absolutePos.y,
		self.viewport.w, self.viewport.h );
	
	-- Border shapes
	shapeCount = shapeCount + -- Debug
		self:drawPolys(
			self.shapes.borderPolys, 
			self.colors.borderShapesOutline,
			self.colors.borderShapesFill);
	
	-- Static shapes
	shapeCount = shapeCount + -- Debug
		self:drawPolys(
			self.shapes.staticPolys,
			self.colors.staticShapesOutline,
			self.colors.staticShapesFill);
	shapeCount = shapeCount + -- Debug
		self:drawCircles(
			self.shapes.staticCircles,
			self.colors.staticShapesOutline,
			self.colors.staticShapesFill);
	
	-- Moving shapes
	shapeCount = shapeCount + -- Debug
		self:drawPolys(
			self.shapes.movingPolys,
			self.colors.movingShapesOutline,
			self.colors.movingShapesFill);
	shapeCount = shapeCount + -- Debug
		self:drawCircles(
			self.shapes.movingCircles,
			self.colors.movingShapesOutline,
			self.colors.movingShapesFill);
	
	-- Sensor shapes
	shapeCount = shapeCount + -- Debug
		self:drawPolys(
			self.shapes.sensorPolys,
			self.colors.sensorShapesOutline,
			self.colors.sensorShapesOutline);
	shapeCount = shapeCount + -- Debug
		self:drawCircles(
			self.shapes.sensorCircles,
			self.colors.sensorShapesOutline,
			self.colors.sensorShapesOutline);
	
	-- Mouse joint
	if(self.mouseJointHolder.joint)then
		self:drawMouseJoint(self.mouseJointHolder.joint);
	end;	
	
	-- Restore enviroment
	love.graphics.setColor( origColor );
	if origScissor then 
		love.graphics.setScissor( origScissor );
	else
		love.graphics.setScissor() 
	end;
	self:drawOutline();
	--console:printLn("<physCam:draw> shapecount:"..shapeCount);
end;

function PhysCamera:getZoom()
	return self.zoomVolume;
end;

function PhysCamera:moveOnWorld( pixelsX, pixelsY )
	--[[ old conversions
	self.worldPos.x = self.worldPos.x + 
		pixelsX*(battledale.B2METERS_IN_PIXEL/self.zoomVolume);
	self.worldPos.y = self.worldPos.y + 
		pixelsY*(battledale.B2METERS_IN_PIXEL/self.zoomVolume);
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
				*battledale.B2METERS_IN_PIXEL)
					/self.zoomVolume),
		self.worldPos.y
			+(((screenY - (self.viewport.absolutePos.y+self.viewport.h/2))
				*battledale.B2METERS_IN_PIXEL)
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

return newPhysCamera;

end; -- End of enclosing function

