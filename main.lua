--[[
________________________________________________________________________________

                                                                   BattleDrive
                     Copyright (C) 2007-2011 Petr Ohlidal <An00biS@An00biS.cz>

_________________________________ License ______________________________________

This software is provided 'as-is', without any express or implied
warranty.  In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
	claim that you wrote the original software. If you use this software
	in a product, an acknowledgment in the product documentation would be
	appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be
	misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.

________________________________________________________________________________

This is the main script of BD. It loads and inits the libraries and runs the
MainMenu app.

________________________________________________________________________________

--]]
--[[--#DBG_PROFILE#
DBG_mainTime = love.timer.getTime();

--------------------------------------------------------------------------------
-- Prints difference between current time and specified global time variable;sets the global var to current time.
-- @param timeVarName string The name of the global time variable
-- @param msg string Message to print
-- @example DBG_markTime("DBG_time", "action done") -- Prints DBG action done in [time] sec.
--------------------------------------------------------------------------------
function DBG_markTime(timeVarName,msg)
	local t = love.timer.getTime();
	print("DBG "..tostring(msg).." in "..t-_G[timeVarName].." sec");
	_G[timeVarName]=t;
end

function DBG_markMainTime(msg)
	DBG_markTime("DBG_mainTime",msg);
end
--]]

local BD_Config = require "config.lua";

require "Libs/middleclass/middleclass.lua"

function love.run()
	--[[--#DBG_PROFILE#
		DBG_markMainTime("love.run started")--]]
	-- Optimization
	local love = love;
	local love_timer_step = love.timer.step;
	local love_timer_getDelta = love.timer.getDelta;
	local love_timer_sleep = love.timer.sleep;
	local love_graphics = love.graphics;
	local love_graphics_clear = love.graphics.clear;
	local love_graphics_present = love.graphics.present;
	local love_event_poll = love.event.poll;
	local love_mouse_getPosition = love.mouse.getPosition;

	love_graphics.setCaption("BattleDrive");
	love_graphics.setMode(BD_Config.screenWidth, BD_Config.screenHeight, false, false, 0);
	love_graphics_clear();
	local font12 = love.graphics.newFont(12);
	love_graphics.setFont(font12);
	love_graphics.print("LOADING...",50,50);
	love_graphics_present();

   --[[ Log file (Windows)
	local logFile = io.open("BD_Log.txt","w");
	local logStream = io.output(logFile);
	logStream:write("This is BattleDrive")
	print = function(...)
	    logStream:write(...);
	    logStream:write("\n");
	end
	--]]

	-- Load libs
	BDT = require (BD_Config.frameworkDir.."/BDT.lua");
	BDT:init(BD_Config.frameworkDir);
	BDT_GUI = BDT:loadLibrary("GUI");

	-- Define global app variables.
	BD_MenuApp = false;
	BD_GameApp = false; -- The game object - to be loaded.
	BD_ActiveApp = false;

	local newMainMenuApp = require "BD_MainMenuApp.lua";
	BD_MenuApp = newMainMenuApp(BD_Config);
	BD_MenuApp:initialize();
	BD_ActiveApp = BD_MenuApp;
	BD_Exit = false;

	local mouseX, mouseY, mouseOldX, mouseOldY = 0,0,0,0;

	local dt = 0;
	-- Main event loop
	while not BD_Exit do
		-- Alias
		local app = BD_ActiveApp;

		-- Update
		love_timer_step();
		dt = love_timer_getDelta();
		app:update(dt);

		-- Draw
		love_graphics_clear();
		app:draw();

		-- Emulate mouse-move event
		mouseX, mouseY = love_mouse_getPosition();
		if mouseX ~= mouseOldX or mouseY ~= mouseOldY then
			app:mouseMoved(mouseX, mouseY, mouseOldX, mouseOldY);
		end
		mouseOldX, mouseOldY = mouseX, mouseY;

		-- Handle events
		for evType, a,b,c,d in love_event_poll() do
		   if evType=="q" then
		      love.audio.stop();
		      return
		   end
		   app:handleEvent(evType,a,b,c,d);
		end

		-- Sleep
		love_timer_sleep(1);

		-- Present
		love_graphics_present();
	end
end
