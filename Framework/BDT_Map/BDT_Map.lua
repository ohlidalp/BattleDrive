return function( BDT_Map_Dir ) -- Closure

local Map = {};
Map.__index = Map;

--- Create a new map

-- The map is divided into rectangular areas called parcels.
-- Static map obstacles are anchored in parcels. This makes their lookup faster.
-- Map size is not set directly, but by setting parcel size and then map size in parcels
-- @param _parcelW Parcel width in pixels
-- @param _parcelH Parcel height in pixels
-- @param _mapW Map width in parcels
-- @param _mapH Map height in parcels

-- The map is not tile-based, but tiling is present to make graphical design easier
-- Tile size is fully up to you, but if the map pixel size is not divisible by the tile size,
-- you'll encounter the effect of the tiled surface going beyond the map borders.
-- Note: Vector graphics are not pixel-perfect, seams are visible when scrolling tiled map.
-- For that reason, input the tile size 1px smaller than the image (50x35 for 51x36 image)
-- @param _tileset Table containig love graphics (indexing method doesnt matter)
-- @param _tileW Width of a tile in pixels
-- @param _tileH Height of a tile in pixels
local function newMap( _parcelW, _parcelH, _mapW, _mapH, _tileset, _tileW, _tileH )
	local m = {};

	m.constants = {};
	-- Tile size in pixels
	m.constants.tile = { w=_tileW, h=_tileH };
	-- Parcel size in pixels
	m.constants.parcel = { w=_parcelW, h=_parcelH };
	-- Map size in parcels
	m.constants.map = { w=_mapW, h=_mapH };

	m.tileset = _tileset;

	local mapPixW = m.constants.map.w*m.constants.parcel.w;
	local mapPixH = m.constants.map.h*m.constants.parcel.h;
	local arrayW, arrayWrem = math.modf(mapPixW/m.constants.tile.w);
	if (arrayWrem ~= 0) then arrayW = arrayW+1 end
	local arrayH, arrayHrem = math.modf(mapPixH/m.constants.tile.h);
	if (arrayHrem ~= 0) then arrayH = arrayH+1 end
	--[[
	print("<new map> arrayW:", arrayW, "arrayH:", arrayH, "wrem:",
		arrayWrem, "hrem:", arrayHrem);
	--]]
	m.constants.array = {w=arrayW,h=arrayH};
	m.tiles = {};

	return setmetatable(m, Map);
end

function Map:getTile(x,y)
	return self.tiles[y] and self.tileset[self.tiles[y][x]] or nil;
end

function Map:getTileIndex(x,y)
	return self.tiles[y] and self.tiles[y][x] or nil;
end

-- Returns the
function Map:getPixelSize( )
	return
		self.constants.map.w*self.constants.parcel.w,
		self.constants.map.h*self.constants.parcel.h;
end

function Map:getPixelWidth()
	return self.constants.map.w*self.constants.parcel.w;
end

function Map:getPixelHeight()
	return self.constants.map.h*self.constants.parcel.h;
end

return {newMap = newMap};

end -- End of closure
