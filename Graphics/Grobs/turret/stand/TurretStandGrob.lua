-- turret stand grob
-- imageArea=AABB
--[[ OLD
--spriteStep=0
spriteCount=1
spritesDir='graphics/turret/stand/'
sprites = {spritesDir..'sprite.png'};
--singleImageArea = {x=-31,y=-37,w=61,h=59 }
singleShade = {x=-28,y=-19,w=55,h=39}
--]]
spriteStep=0
spritesDir='graphics/turret/stand/'
sprites = {spritesDir..'sprite.png'};
-- old rectangle singleImageArea = {x=-30.2516,y=-37.213,w=61,h=59 }
singleImageArea = {x1=-30.2516,y1=-37.213,x2=31,y2=22 }
singleShade = {x=-27.2516,y=-19.213,w=54,h=39}
pegs = {};
--local pegY = 50;
pegs[1] = {
	singlePeg={ x=0,y=-26.7055,h=26.7055}
	--singlePeg={ x=0,y=-pegY,h=pegY};
};

