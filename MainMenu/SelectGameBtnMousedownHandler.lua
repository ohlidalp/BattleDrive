--------------------------------------------------------------------------------
-- @class table
-- @name class SelectGameBtnMousedownHandler
-- @description Handler for 'select game' button at 'select game' screen.
-- @field menuApp MainMenuApp
--------------------------------------------------------------------------------

local SelectGameBtnMousedownHandler = {};
SelectGameBtnMousedownHandler.__index = SelectGameBtnMousedownHandler;

local function newSelectGameBtnMousedownHandler(mainMenu)
   return setmetatable({menuApp=mainMenu},SelectGameBtnMousedownHandler);
end
--------------------------------------------------------------------------------
--
--------------------------------------------------------------------------------
function SelectGameBtnMousedownHandler:run(sheet)
	--[[--#DBG#
		print("IN SelectGameBtnMousedownHandler:run");--]]
   local menuApp = self.menuApp;
   menuApp:launchSelectedGame();
end

return  newSelectGameBtnMousedownHandler;