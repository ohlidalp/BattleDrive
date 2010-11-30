local GameSheetMouseDownHandler = {};
GameSheetMouseDownHandler.__index = GameSheetMouseDownHandler;

local function newGameSheetMouseDownHandler(app,gameInfo)
	if type(app)~="table" then
	   error("ERROR: newGameSheetMouseDownHandler: invalid arg 'app', expected table,got ["..tostring(app).."]")
	end
	if type(gameInfo)~="table" then
	   error("ERROR: newGameSheetMouseDownHandler: invalid arg 'gameInfo', expected table,got ["..tostring(gameInfo).."]")
	end
   return setmetatable({
		app=app,
		gameInfo=gameInfo,
		},GameSheetMouseDownHandler);
end

function GameSheetMouseDownHandler:run(sheet,x,y,button)
	self.app:selectGame(self.gameInfo);
end

return newGameSheetMouseDownHandler;