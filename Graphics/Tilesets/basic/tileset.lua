-- Tileset definition file
-- Sets up a global var 'Tileset'

local s = 64;

-- xy = grid pos
local function tile(name, y, x)
	return {name=name, x=x*s, y=y*s, w=s, h=s}
end

Tileset = {
	-- Image filename
	imageFilename = "Tileset.png",
	-- Image dimensions
	imageWidth = 256,
	imageHeight = 640,
	-- Tile dimensions
	tileWidth = s,
	tileHeight = s,
	-- Array of tile coordinates
	coords = {
		{name="HighGroundEdgeTL-AA",x=0, y=0,w=s,h=s}, --1
		tile("HighGroundEdgeTL-BA",1,0), --2
		tile("HighGroundEdgeTR-AA",2,0), --3
		tile("HighGroundEdgeTR-BA",3,0), --4
		tile("HighGroundWestCornerBL-AA",0,1), --5
		tile("HighGroundWestCornerBL-BA",1,1), --6
		tile("HighGroundWestCornerBL-AB",0,2), --7
		tile("HighGroundWestCornerBL-BB",1,2), --8
		tile("HighGroundT1",2,1),         --9
		tile("HighGroundT2",3,1),         --10
		tile("HighGroundEdgeBL-AA",2,2 ), --11
		tile("HighGroundEdgeBL-AB",3,2 ), --12
		tile("HighGroundEdgeBL-BA",2,3 ), --13
		tile("HighGroundEdgeBL-BB",3,3 ), --14
		tile("GrassGreener",3,0),         --15
		tile("Grass",3,1),                --16
		tile("PavementEdgeTL-AA",4,0),    --17
		tile("PavementEdgeTL-AB",4,1),
		tile("PavementEdgeTR-AA",4,2),
		tile("PavementEdgeTR-AB",4,3),
		tile("PavementEdgeBL-AA",5,0),
		tile("PavementEdgeBL-AB",5,1),
		tile("PavementEdgeBR-AA",5,2),
		tile("PavementEdgeBR-AB",5,3),    --24
		tile("WaterT1",5,0),              --25
		tile("WaterT2",6,0),              --26
		tile("Pavement-AA",7,1),          --27
		tile("Pavement-BA",7,2),
		tile("Pavement-CA",7,3),
		tile("Pavement-AB",8,1),
		tile("Pavement-BB",8,2),
		tile("Pavement-BC",8,3),
		tile("WaterEdgeTL-AA",8,0),       --33
		tile("WaterEdgeTL-AB",8,1),
		tile("WaterEdgeTR-AA",8,2),
		tile("WaterEdgeTR-AB",8,3),
		tile("WaterEdgeBL-AA",9,0),       --37
		tile("WaterEdgeBL-AB",9,1),
		tile("WaterEdgeBR-AA",9,2),
		tile("WaterEdgeBR-AB",9,3),
	}
}