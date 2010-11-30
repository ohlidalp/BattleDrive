return function ( BDT )

local Instant = {};

--- Creates a love.physics world of given size + 1 b2Meter wide borders.
-- @param worldW number World width in b2Meters
-- @param worldH number World height in b2Meters
-- @param sleep boolean Flag whether to activate sleeping in the world
-- @return The physics world
-- @return The ground body
function Instant.physWorld( worldW, worldH, sleep, borderPolys, gravityX, gravityY )
	sleep = sleep~=nil and sleep or true;
	gravityX = gravityX or 0;
	gravityY = gravityY or 0;
	-- Physics world
	local world = love.physics.newWorld(
			-1, -1, (worldW)+1, (worldH)+1, gravityX, gravityY, sleep );
	local ground = love.physics.newBody( world, 0, 0, 0 );

	-- Top
	borderPolys.top = love.physics.newPolygonShape(
		ground,  0,-1,   worldW+1,-1,   worldW+1,0,   0,0 );
	-- Bottom
	borderPolys.bottom = love.physics.newPolygonShape( ground,
		-1, worldH,
		worldW,worldH,
		worldW,worldH+1,
		-1, worldH+1);
	-- Left
	borderPolys.left = love.physics.newPolygonShape( ground,
		-1,-1,
		0,-1,
		0,worldH,
		-1, worldH );
	-- Right
	borderPolys.right = love.physics.newPolygonShape( ground,
		worldW, 0,
		worldW+1, 0,
		worldW+1, worldH+1,
		worldW, worldH+1 );
	return world,ground;
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

	--[ [
	-- Debug print
	print("<Checker map> w:", map.constants.array.w, "h:", map.constants.array.h);
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