--[[
________________________________________________________________________________

                                                                   BattleDrive
                                                                   Version 0.1
                       Copyright (C) 2007-2010 Petr Ohlidal <An00biS@email.cz>

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

This is a main menu program. It displays the main menu and lists games.

________________________________________________________________________________

--]]

--[ [--#DBG_PROFILE#
DBG_MainMenuAppTime = love.timer.getTime();

local function DBG_markMenuTime(msg)
	DBG_markTime("DBG_MainMenuAppTime",msg);
end
--]]



--------------------------------------------------------------------------------
-- @class table
-- @name class MainMenuApp
-- @description The BD main menu application.
-- @field gameInfos Table; a list of BDGameInfo object describing games.
-- @field selectedGame table 'gameinfo'
-- @field desk Table(Desk); the GUI's desk object
-- @field config table Configuration.
-- @field config.gamesDir String; directory where games are stored. default="Programs"
-- @field config.graphicsDir String; directory where graphics are stored. default="Graphics"
-- @field config.frameworkDir String; directory where BDT is stored. default="Framework"
-- @field config.gamesListItemHeight Number
-- @field config.gamesListItemWidth number
-- @field screenDirty Boolean;
-- @field gameListSheet Sheet
-- @field gameNameSheet Sheet;
-- @field gameNameText SheetTextContent
-- @field gameDescSheet Sheet;
-- @field gameDescText SheetTextContent
-- @field startGameBtnSheet Sheet
-- @field confGameBtnSheet Sheet
-- @field uiOriginX number GUI has a fixed size; It's allways placed in center of screen; This is the GUI X offset;
-- @field uiOriginY number GUI Y offset
-- @field fonts table
-- @field handlers table Event handling functions, indexed by love.event.Event enum values.
--------------------------------------------------------------------------------
local MainMenuApp = {};
MainMenuApp.__index = MainMenuApp;
MainMenuApp.__tostring = function()
	return "BD_MainMenuApp"
end

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

--------------------------------------------------------------------------------
-- Enumerates available BD games; Checks required attributes.
--------------------------------------------------------------------------------
function MainMenuApp:enumerateGames()
	print("Looking for games...");
	local gameInfoFiles = love.filesystem.enumerate(self.config.gamesDir);
	local gameInfos = {};
	for index,infoFile in ipairs(gameInfoFiles) do
		infoFile = self.config.gamesDir..'/'..infoFile;
		if love.filesystem.isFile(infoFile) and
				string.sub(infoFile,string.len(infoFile)-2)=="lua" then
			local g = require (infoFile);
			local valid=true;
			local BDT_checkField = BDT.checkField;
			local errMsg = "Warning: invalid game info file '"..infoFile.."'";
			if g==nil or type(g)~="table" then
				print(errMsg.." returned "..tostring(g).." instead of table");
			elseif BDT_checkField(g,"name","string",errMsg)
				and BDT_checkField(g,"gameDir","string",errMsg)
				and BDT_checkField(g,"loaderScriptName","string",errMsg)
			then
				table.insert(gameInfos, g);
				print("\tFound game: "..g.name);
			end
		end
	end
	self.gameInfos = gameInfos;
end

--------------------------------------------------------------------------------
-- Handle a LOVE event
-- @param e string event type (love.event.Event enum)
-- @param a mixed event attribute (depends on event type)
-- @param b mixed event attribute (depends on event type)
-- @param c mixed event attribute (depends on event type)
-- @param d mixed event attribute (depends on event type)
--------------------------------------------------------------------------------
function MainMenuApp:handleEvent(e,a,b,c,d)
	local handler = self.handlers[e];
	if handler then
		handler(self,a,b,c,d);
	else
		print("WARNING: BD_MainMenuApp: unhandled event '"..tostring(e).."' with args: "..tostring(a)..","..tostring(b)..","..tostring(c)..","..tostring(d));
	end
end

--------------------------------------------------------------------------------
-- Re-create the GUI list of games; must be called after the UI is created.
--------------------------------------------------------------------------------
function MainMenuApp:updateUIGamesList()
	local config=self.config;
	local gameListSheet = self.gameListSheet;
	gameListSheet:removeAllSheets();
	local itemHeight = self.config.gamesListItemHeight;
	local itemWidth = self.config.selectGameScreen_RightCollumnWidth;
	local gameIndex = 0;

	for i,gameInfo in ipairs(self.gameInfos) do
		local itemY = i * (itemHeight + 1) - itemHeight;
		local gameSheet = gameListSheet:newSheet(0,itemY,itemWidth,itemHeight);
		local sheetRend = BDT_GUI.newSheetRenderer(gameSheet);
		local sheetText = BDT_GUI.newSheetTextContent(gameInfo.name,5,5,self.fonts.default12,itemWidth);
		sheetText:setAlign("left");
		sheetRend:addContent(sheetText);
		gameSheet:addEventHandler(BDT_GUI.events.MOUSEDOWN,
			newGameSheetMouseDownHandler(self,gameInfo));
		gameSheet:setName("Game="..gameInfo.name);
	end
	self:selectGame(self.gameInfos[1]);
end

--------------------------------------------------------------------------------
-- Setup the menu app.
--------------------------------------------------------------------------------
function MainMenuApp:initialize()
	-- Aliases
	local love_graphics = love.graphics;
	local love_graphics_newFont = love_graphics.newFont;
	-- Load fonts
	local fonts = self.fonts;
	fonts.default12 = love_graphics_newFont(12);
	local kimPath = "Graphics/Fonts/Kimberley/kimberley.ttf";
	fonts.kimberley12 = love_graphics_newFont(kimPath, 12);
	fonts.kimberley24 = love_graphics_newFont(kimPath, 24);
	fonts.kimberley48 = love_graphics_newFont(kimPath, 48);
	love_graphics.setFont(fonts.default12);
	-- Create interface
	local screenWidth = love.graphics.getWidth();
	local screenHeight = love.graphics.getHeight();
	if screenWidth>1024 then
		self.uiOriginX = math.floor((screenWidth-1024)/2)
	else
		self.uiOriginX=0;
	end
	if screenHeight>768 then
		self.uiOriginY = math.floor((screenHeight-768)/2)
	else
		self.uiOriginY=0;
	end
	self.desk = BDT_GUI.newDesk();
	self:enumerateGames();
	self:showSelectGameScreen();
	self:updateUIGamesList();
end

--------------------------------------------------------------------------------
-- Creates (once) and displays the 'select game' screen.
--------------------------------------------------------------------------------
function MainMenuApp:showSelectGameScreen()
	local desk = self.desk;
	if not self.gameListSheet then -- Create interface if it doesn't exist.
		local config = self.config;
		local uiOriginX = self.uiOriginX;
		local uiOriginY = self.uiOriginY;
		local uiHeight = config.uiHeight;
		local uiWidth = config.uiWidth;
		local consoleHeight = 250;
		local rightCollumnW = config.selectGameScreen_RightCollumnWidth;
		local rightCollumnX = uiOriginX+uiWidth-5-rightCollumnW;
		local leftCollumnW = uiWidth-15-rightCollumnW;
		local nameSheetH = 50;
		local selectBtnH = 50;

		-- Game name sheet
		local gameNameSheet = desk:newSheet(uiOriginX+5,uiOriginY+5,leftCollumnW,nameSheetH);
		gameNameSheet:setActive(false);
		self.gameNameSheet = gameNameSheet;
		gameNameSheet:setName("GameName");
		local gameNameSheetR = BDT_GUI.newSheetRenderer(gameNameSheet);
		local gameNameText = BDT_GUI.newSheetTextContent("...",0,10,self.fonts.kimberley24,leftCollumnW);
		gameNameText:setAlign("center");
		self.gameNameText = gameNameText;
		gameNameSheetR:addContent(gameNameText);

		-- Game desc sheet
		local gameDescSheet = desk:newSheet(uiOriginX+5,uiOriginY+10+nameSheetH,leftCollumnW,uiHeight-15-consoleHeight-nameSheetH);
		self.gameDescSheet = gameDescSheet;
		gameDescSheet:setName("GameDesc");
		local gameDescSheetR = BDT_GUI.newSheetRenderer(gameDescSheet);
		local gameDescText = BDT_GUI.newSheetTextContent("...",5,5,self.fonts.default12,leftCollumnW-10);
		gameDescText:setAlign("left");
		gameDescSheet:setActive(false);
		gameDescSheetR:addContent(gameDescText);
		self.gameDescText = gameDescText;

		-- Game list sheet
		self.gameListSheet = desk:newSheet(rightCollumnX,uiOriginY+5,rightCollumnW,uiHeight-consoleHeight-10);
		self.gameListSheet:setName("GameList");

      -- Select game btn sheet
		local selectGameBtnSheet = desk:newSheet(rightCollumnX,uiOriginY+uiHeight-5-selectBtnH,rightCollumnW,selectBtnH)
		self.selectGameBtnSheet=selectGameBtnSheet;
		local selectGameBtnSheetR = BDT_GUI.newSheetRenderer(selectGameBtnSheet);
		local selectGameBtnText = BDT_GUI.newSheetTextContent("Select",0,10,self.fonts.kimberley24,rightCollumnW);
		selectGameBtnText:setAlign("center");
		selectGameBtnSheetR:addContent(selectGameBtnText);
		local handler = { -- button press handler
			menuApp = self,
			run = function (self)
				local menuApp = self.menuApp;
				menuApp:launchSelectedGame();
			end
		};
		selectGameBtnSheet:addEventHandler(BDT_GUI.events.MOUSEDOWN,handler);
		selectGameBtnSheet:setName("SelectGameBtn");
	else
		desk:attachSheet(self.gameNameSheet);
		desk:attachSheet(self.gameDescSheet);
		desk:attachSheet(self.selectGameBtnSheet);
		desk:attachSheet(self.gameListSheet);
	end
end;

function MainMenuApp:draw()
	self.desk:draw();

end

function MainMenuApp:update(dt)
	local love_mouse = love.mouse;
	local mouseX = love_mouse.getX();
	local mouseY = love_mouse.getY();
	if( mouseX~=self.lastMouseX or mouseY~=self.lastMouseY ) then
		self.desk:mouseMoved(mouseX,mouseY,self.lastMouseX,self.lastMouseY);
		self.lastMouseX=mouseX;
		self.lastMouseY=mouseY;
	end
end

function MainMenuApp:keyPressed(key,unicode)
	--self.desk:keyPressed(key,unicode);
end

function MainMenuApp:keyReleased(key)
	--self.desk:keyReleased(key);
end

function MainMenuApp:mousePressed(x,y,button)
	self.desk:mousePressed(x,y,button)
end

function MainMenuApp:mouseReleased(x,y,button)
	self.desk:mouseReleased(x,y,button)
end

--------------------------------------------------------------------------------
-- Launches a game. Manipulates global BD_ActiveApp, BD_GameApp variables.
-- @param g GameInfo
--------------------------------------------------------------------------------
function MainMenuApp:launchGame(g)
	local gameDir = self.config.gamesDir.."/"..g.gameDir
	local loader = require(gameDir.."/"..g.loaderScriptName);
	local gameApp = loader:load(self,gameDir);
	BD_ActiveApp = gameApp;
	BD_GameApp = gameApp;
end

function MainMenuApp:launchSelectedGame()
   self:launchGame( self.selectedGame);
end

--------------------------------------------------------------------------------
-- Take control and terminate the current game.
--------------------------------------------------------------------------------
function MainMenuApp:endGame()
	BD_ActiveApp = BD_MenuApp;
	BD_GameApp:cleanup();
	BD_GameApp = nil;
end

--------------------------------------------------------------------------------
-- Sets app's 'selectedGame' field and updates 'select game' screen.
-- @param g GameInfo
--------------------------------------------------------------------------------
function MainMenuApp:selectGame(g)
	self.selectedGame = g;
	self.gameNameText:setText(g.name);
	self.gameDescText:setText(g.description);
end

function MainMenuApp:getConfig()
	return self.config;
end

function MainMenuApp:getFonts()
	return self.fonts;
end

--------------------------------------------------------------------------------
-- Constructor
-- @param config table Configuration from main script
-- @param font12 LOVE.graphics.Font Default font at size 12, or nil
--------------------------------------------------------------------------------
function newMainMenuApp(config,font12)
	local config = {
		gamesDir = config.gamesDir,
		graphicsDir = config.graphicsDir,
		frameworkDir = config.frameworkDir,
		gamesListItemHeight=30;
		selectGameScreen_RightCollumnWidth=400;
		uiHeight = 650;
		uiWidth = 1000;
		fonts = {default12=font12}
	};
	local handlers = {
		kp = MainMenuApp.keyPressed,
		kr = MainMenuApp.keyReleased,
		mp = MainMenuApp.mousePressed,
		mr = MainMenuApp.mouseReleased
	}
	return setmetatable({
		config=config;
		screenDirty = true;
		lastMouseX = 0;
		lastMouseY = 0;
		fonts = {},
		handlers = handlers
	},
	MainMenuApp);
end

return newMainMenuApp;
