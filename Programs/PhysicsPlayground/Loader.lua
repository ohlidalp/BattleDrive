-- PhysicsPlayground loader object

local Loader = {};
Loader.__index = Loader;

function Loader:load(core, gameDir)
	print(" ==== Physics Playground: Loading ====");
	local config = core:getConfig();
	local love_graphics = love.graphics;
	love_graphics.clear();
	love_graphics.setColor(255,255,255,255);
	love_graphics.print("LOADING 'PhysicsPlayground' ...",50,50);
	love_graphics.present();
	local love_timer_getTime = love.timer.getTime;
	local startTime = love_timer_getTime();
	-- Global BDT objects
	BDT_Common    = BDT:loadLibrary("Common");
	BDT_Map       = BDT:loadLibrary("Map");
	BDT_Instant   = BDT:loadLibrary("Instant");
	BDT_GfxCamera = BDT:loadLibrary("GfxCamera");
	BDT_AI        = BDT:loadLibrary("AI");
	BDT_GUI       = BDT:loadLibrary("GUI");
	BDT_Grob      = BDT:loadLibrary("Grob");
	local constructor = require(gameDir.."/Application.lua");
	print("Scripts loaded: "..love_timer_getTime()-startTime.." sec");
	local app = constructor(core,gameDir);
	print(" ==== Physics Playground: Start ====");
	return app;
end

return Loader;

