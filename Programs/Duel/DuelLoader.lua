--[[
________________________________________________________________________________

 Duel loader
________________________________________________________________________________

--]]

local Loader = {};
Loader.__index = Loader;

function Loader:load(core, gameDir)
	print(" ==== Duel: Loading ==== ");
	local config = core:getConfig();
	local love_graphics = love.graphics;
	BDT_Map       = BDT:loadLibrary("Map");
	BDT_GfxCamera = BDT:loadLibrary("GfxCamera");
	BDT_Grob      = BDT:loadLibrary("Grob");
	BDT_Turntable = BDT:loadLibrary("Turntable");
	BDT_Undercart = BDT:loadLibrary("Undercart");
	BDT_Misc      = BDT:loadLibrary("Misc");
	BDT_Entities  = BDT:loadLibrary("Entities");
	love_graphics.clear();
	love_graphics.setColor(255,255,255,255);
	love_graphics.print("LOADING 'Duel' ...",50,50);
	love_graphics.present();
	local love_timer_getTime = love.timer.getTime;
	local startTime = love_timer_getTime();
	local constructor = require(gameDir.."/DuelApp.lua");
	print("Scripts loaded in: "..love_timer_getTime()-startTime.." sec");
	local app = constructor(core, gameDir);
	print(" ==== Duel: Start ==== ");
	return app;
end

return Loader;
