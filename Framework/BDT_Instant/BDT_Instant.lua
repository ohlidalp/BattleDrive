return function ( BDT_Instant_Dir )

local Instant = {};

--- Creates a love.physics world of given size + 1 b2Meter wide borders.
-- @param x1 number x1 coordinate in b2Meters
-- @param y1 number y1 coordinate in b2Meters
-- @param x2 number x2 coordinate in b2Meters
-- @param y2 number y2 coordinate in b2Meters
-- @param meter Length of b2Meter in pixels.
-- @param sleep boolean Flag whether to activate sleeping in the world
-- @return The physics world
-- @return love.physics.Body ground body
-- @return love.physics.RectangleShape top border
-- @return love.physics.RectangleShape bottom border
-- @return love.physics.RectangleShape left border
-- @return love.physics.RectangleShape right border
function Instant.createFencedPhysWorld( x1, y1, x2, y2, meter, gravityX, gravityY, sleep )
	sleep = sleep~=nil and sleep or true;
	gravityX = gravityX or 0;
	gravityY = gravityY or 0;
	local love_physics = love.physics;
	local love_physics_newRectangleShape = love_physics.newRectangleShape;
	local width = x2 - x1;
	local height = y2 - y1;
	local thickness = 5; -- Width of border polygons (in pixels)
	-- Physics world
	local world = love_physics.newWorld(
			x1-1, y1-1, x2+1, y2+1, gravityX, gravityY, sleep );
	world:setMeter(meter);
	local ground = love_physics.newBody( world, x1, y1, 0 );
	-- Clockwise order is OK
	-- Top
	bpTop = love_physics_newRectangleShape(ground, x1-1, y1-1, width + 1, thickness, 0 );--0,0, x2,0, 1,x2, 0,1 );
	-- Right
	bpRight = love_physics_newRectangleShape( ground, x2, y1-1, thickness, height + 1, 0 );
	-- Left
	bpLeft = love_physics_newRectangleShape( ground, x1-1, y1, thickness, height + 1, 0 );
	-- Bottom
	bpBottom = love_physics_newRectangleShape( ground, x2-1, y2, width + 1, thickness, 0);
	return world, ground, bpTop, bpBottom, bpLeft, bpRight;
end;

--- This function paints supplied map with checker pattern and 1 tile wide border
function Instant.checkerMap( map, blackTileIndex, whiteTileIndex, edgeTileIndex )
	map.tiles = {};
	local iXMax = map.constants.array.w;
	local iYMax = map.constants.array.h;
	local iX, iY;
	for iY = 1, iYMax, 1 do
		map.tiles[iY] = {};
		for iX = 1, iXMax, 1 do
			local xi, xf = math.modf(iX/2);
			local yi, yf = math.modf(iY/2);
			map.tiles[iY][iX] = ( (yf~=0) == (xf~=0) ) and blackTileIndex or whiteTileIndex;
		end;
	end;
	-- Top edge
	for iX=1, iXMax, 1 do
		map.tiles[1][iX] = edgeTileIndex;
	end;
	-- Bottom edge
	for iX=1, iXMax, 1 do
		map.tiles[iYMax][iX] = edgeTileIndex;
	end;
	-- Left edge
	for iY=1, iYMax, 1 do
		map.tiles[iY][1] = edgeTileIndex;
	end;
	-- Right edge
	for iY=1, iYMax, 1 do
		map.tiles[iY][iXMax] = edgeTileIndex;
	end;

	--[[
	-- Debug print
	print("[Checker map] w:", map.constants.array.w, "h:", map.constants.array.h);
	for iy, row in ipairs(map.tiles) do
		rowStr = "";
		for ix, t in ipairs(row) do
			rowStr=rowStr..t.." ";
		end;
		print(rowStr);
	end;
	--]]
end;

return Instant;

end; -- End of closure