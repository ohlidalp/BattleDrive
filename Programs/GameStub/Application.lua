--[[
________________________________________________________________________________

 Game stub

 This is a bare skeleton of a BattleDrive game.
 Intended to provide a startpoint from new BD game developers.
 Also serves as a documentation of the game object.
________________________________________________________________________________

--]]

local Application = {};
Application.__index = Application;
Application.__tostring = function()
	return "BattleDrive Game: Stub";
end

--------------------------------------------------------------------------------
-- KeyPressed LOVE callback
--------------------------------------------------------------------------------
function Application:keyPressed(key, unicode)
	-- Exit on escape
	if key == "escape" then
		self:exit();
	end
end

--------------------------------------------------------------------------------
-- KeyReleased LOVE callback
--------------------------------------------------------------------------------
function Application:keyReleased(key)

end

--------------------------------------------------------------------------------
-- Update LOVE callback
-- @param dt DeltaTime - time since last update in seconds.
--------------------------------------------------------------------------------
function Application:update(dt)

end

--------------------------------------------------------------------------------
-- Handle a LOVE event
-- @param e string event type (love.event.Event enum)
-- @param a mixed event attribute (depends on event type)
-- @param b mixed event attribute (depends on event type)
-- @param c mixed event attribute (depends on event type)
-- @param d mixed event attribute (depends on event type)
--------------------------------------------------------------------------------
function Application:handleEvent(e,a,b,c,d)
	if e == "kp" then
		self:keyPressed(a,b);
	end
end

--------------------------------------------------------------------------------
-- Tell this game (externally or internally) to exit
--------------------------------------------------------------------------------
function Application:exit()
	self.core:endGame();
	print(" ==== Game Stub: Exit ==== ");
end

--------------------------------------------------------------------------------
-- Terminate and clean up this game. Should be called externally after exit.
--------------------------------------------------------------------------------
function Application:cleanup()

end

function Application:draw()
	love.graphics.printf("This is a BattleDrive game stub\n\n"
		.."It does nothing, just starts and exits.\n\nPress escape to exit.",
		100,100,love.graphics.getWidth()-100);
end

--------------------------------------------------------------------------------
-- Game constructor
--------------------------------------------------------------------------------
return function(bdCore)
	return setmetatable({
		core = bdCore;
		gameDir = gameDir;
	}, Application);
end

