--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_Map
-- @description Game map

-- The map is not tile-based, but tiling is present to make graphical design easier
-- Tile size is fully up to you, but if the map pixel size is not divisible by the tile size,
-- you'll encounter the effect of the tiled surface going beyond the map borders.

-- Note: Vector graphics are not pixel-perfect, seams are visible when scrolling tiled map.
-- For that reason, input the tile size 1px smaller than the image (50x35 for 51x36 image)
-- The map is divided into rectangular areas called parcels.
-- Static map obstacles are anchored in parcels. This makes their lookup faster.
-- Map size is not set directly, but by setting parcel size and then map size in parcels
--------------------------------------------------------------------------------
return function( BDT_Map_Dir ) -- Closure

local BDT_Map = {};

--------------------------------------------------------------------------------
-- @class class
-- @name Map
--------------------------------------------------------------------------------
local Map = {};
Map.__index = Map;

--------------------------------------------------------------------------------
-- Create a new map
-- @param parcelW Parcel width in pixels
-- @param parcelH Parcel height in pixels
-- @param mapW Map width in parcels
-- @param mapH Map height in parcels
-- @param image love.graphics.Image The tileset image.
-- @param quads Table List of love.graphics.Quad objects.
-- @param array2d Table Two-dimensional array of tile indices.
-- @param tileW Width of a tile in pixels
-- @param tileH Height of a tile in pixels
--------------------------------------------------------------------------------
function BDT_Map.newMap( parcelW, parcelH, mapW, mapH, image, quads, array2d, tileW, tileH )
	BDT.checkArg("BDT_Map.newMap", "quads", quads, "table");
	local m = {
		-- Parcel size in pixels
		parcelW = parcelW,
		parcelH = parcelH,
		-- Map size in parcels
		mapW = mapW,
		mapH = mapH,
		quads = quads,
		image = image,
		array2d = array2d,
		tileW = tileW,
		tileH = tileH,
	};
	return setmetatable(m, Map);
end

--------------------------------------------------------------------------------
-- Returns [x, y] map size
-- @return : number Width in pixels
-- @return : number Height in pixels
--------------------------------------------------------------------------------
function Map:getPixelSize( )
	return self.mapW * self.parcelW, self.mapH * self.parcelH;
end

--------------------------------------------------------------------------------
-- Returns map size
-- @return : number Width in pixels
--------------------------------------------------------------------------------
function Map:getPixelWidth()
	return self.mapW * self.parcelW;
end

--------------------------------------------------------------------------------
-- Returns map size
-- @return : number Height in pixels
--------------------------------------------------------------------------------
function Map:getPixelHeight()
	return self.mapH * self.parcelH;
end

--------------------------------------------------------------------------------
-- Returns [w, h] tile size in pixels
-- @return : number tile width
-- @return : number tile height
--------------------------------------------------------------------------------
function Map:getTileSize()
	return self.tileW, self.tileH;
end

---
function Map:getImage()
	return self.image;
end

---
function Map:getArray()
	return self.array2d;
end

--------------------------------------------------------------------------------
-- Returns a quad corresponding to tile.
-- @param x : number Tile x pos
-- @param y : number Tile y pos
--------------------------------------------------------------------------------
function Map:getQuad(x,y)
	if not x or not y then
		return nil;
	else
		local row = self.array2d[y];
		if not row then
			return nil;
		end
		local tileIdx = self.array2d[y][x];
	-- print(string.format("DBG Map:getQuad() x=%2d y=%2d tileIdx=%d",x,y,tileIdx));
		return self.quads[tileIdx];
	end
end

--------------------------------------------------------------------------------
-- Parses list of tile-coords into a list of love.graphics.Quad. Keeps indices.
-- @param coords : table Array of coords
-- @param imgW : number Tileset image width in pixels
-- @param imgH : number Tileset image height in pixels
-- @return : table Array of Quads.
--------------------------------------------------------------------------------
function BDT_Map.loadTilesetFromArray(coords, imgW, imgH)
	local t = {};
	local ins = table.insert;
	local q = love.graphics.newQuad;
	-- print("DBG BDT_Map.loadTilesetFromArray");
	for i, c in ipairs(coords) do
		-- print(string.format("DBG quad: i=%d name=%25s x=%2d y=%d w=%d h=%d",i,c.name,c.x,c.y,c.w,c.h));
		ins(t, q(c.x, c.y, c.w, c.h, imgW, imgH));
	end
	return t;
end

--------------------------------------------------------------------------------
-- Loads tileset image and array from file.
-- @param path : string Path to tileset def file.
-- @return : table Array of Quads.
-- @return : string Path to tileset image.
-- @return : number tile width
-- @return : number tile height
-- @return : number image width
-- @return : number image height
--------------------------------------------------------------------------------
function BDT_Map.loadTilesetDataFromFile(path)
	local def = {};
	local readFile = love.filesystem.load(path);
	setfenv(readFile, def);
	readFile();
	local tQuads = BDT_Map.loadTilesetFromArray(
		def.Tileset.coords, def.Tileset.imageWidth, def.Tileset.imageHeight);
	return tQuads, def.Tileset.imageFilename,
			def.Tileset.tileWidth, def.Tileset.tileHeight,
			def.Tileset.imageWidth, def.Tileset.imageHeight;
end

return BDT_Map;

end -- End of closure

--[[ TRASH
	m.constants = {};
	-- Tile size in pixels
	m.constants.tile = { w=_tileW, h=_tileH };

	m.constants.parcel = { w=_parcelW, h=_parcelH };

	m.constants.map = { w=_mapW, h=_mapH };

	m.tileset = _tileset;

	local mapPixW = m.constants.map.w*m.constants.parcel.w;
	local mapPixH = m.constants.map.h*m.constants.parcel.h;
	local arrayW, arrayWrem = math.modf(mapPixW/m.constants.tile.w);
	if (arrayWrem ~= 0) then arrayW = arrayW+1 end
	local arrayH, arrayHrem = math.modf(mapPixH/m.constants.tile.h);
	if (arrayHrem ~= 0) then arrayH = arrayH+1 end

	m.constants.array = {w=arrayW,h=arrayH};
	m.tiles = {};--]]
