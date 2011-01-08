-- Heavy battle hover demo loader object

local Loader = {};
Loader.__index = Loader;

function Loader:load(menuApp,gameDir)
	print("\n ==== Heavy Battle Hover Demo: Loading ====");
	local config = menuApp:getConfig();
	local love_graphics = love.graphics;
	love_graphics.clear();
	love_graphics.setColor(255,255,255,255);
	love_graphics.print("LOADING 'Heavy Battle Hover Demo' ...",50,50);
	love_graphics.present();
	local love_timer_getTime = love.timer.getTime;
	local startTime = love_timer_getTime();
	local constructor = require(gameDir.."/Application.lua");
	print("Heavy Battle Hover Demo Loader: 'Application.lua' script require()d in "..love_timer_getTime()-startTime.." seconds");
	local app = constructor(menuApp,gameDir);
	print(" ==== Heavy Battle Hover Demo: Start ====");
	return app;
end

return Loader;

