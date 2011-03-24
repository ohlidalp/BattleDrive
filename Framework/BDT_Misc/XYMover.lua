--------------------------------------------------------------------------------
-- This file is part of BattleDrive project.
-- @package BDT_Misc
--------------------------------------------------------------------------------

return function (BDT_Misc)

--------------------------------------------------------------------------------
-- @class table
-- @name XYMoverSpec
-- @description Movement parameters for XYMover class
-- @field accX : number
-- @field accY : number
-- @field slowX : number
-- @field slowY : number
-- @field maxX : number
-- @field maxY : number
--------------------------------------------------------------------------------
local _spec = {
	accX = 200;
	accY = 200;
	slowX = 160;
	slowY = 160;
	maxX = 288;
	maxY = 288;
};

--------------------------------------------------------------------------------
-- @class table
-- @name XYMoverControls
-- @description Control keys table for XYMover class
-- @field goDown : string LOVE key code
-- @field goUp : string LOVE key code
-- @field goLeft : string LOVE key code
-- @field goRight : string LOVE key code
--------------------------------------------------------------------------------
local _controls = {
	goDown  = "down",
	goUp    = "up",
	goLeft  = "left",
	goRight = "right",
};

--------------------------------------------------------------------------------
--- Generates smooth XY movement based on keyboard input.
--------------------------------------------------------------------------------
local XYMover = class('BDT_Misc.XYMover');
BDT_Misc.XYMover = XYMover;

--------------------------------------------------------------------------------
-- @param spec : table
-- @param controls : table
-- @param callback : function
--------------------------------------------------------------------------------
function XYMover:initialize (spec, controls, callback)
	spec = spec or _spec;
	self.acceleration = {x = spec.accX, y = spec.accY};--{ x=150,y=150},
	self.slowdown = {x = spec.slowX, y = spec.slowY};--{ x=166,y=166 },
	self.maxSpeed = {x = spec.maxX, y = spec.maxY};--{ x=222,y=222 },
	self.speed = {x = 0, y = 0};
	self.moveObject = callback;
	-- Movement attributes are now in the root
	self.goLeft = false;
	self.goRight = false;
	self.goUp = false;
	self.goDown = false;
	self.controls = controls or _controls;
end

--------------------------------------------------------------------------------
-- @param elapsed : number Delta time in seconds
--------------------------------------------------------------------------------
function XYMover:update (elapsed)
	--local signs = newVector( self.speed.x > 0 and 1 or -1, self.speed.y > 0 and 1 or -1 );
	local signs = {x = self.speed.x > 0 and 1 or -1, y = self.speed.y > 0 and 1 or -1};

	if( self.goLeft ~= self.goRight ) then
		self.speed.x = self.speed.x + ( elapsed*self.acceleration.x * ( self.goLeft==true and -1 or 1 ) );
		if math.abs( self.speed.x ) > self.maxSpeed.x then self.speed.x = self.maxSpeed.x*signs.x; end;
	elseif self.speed.x ~= 0 then
		self.speed.x = self.speed.x + ( elapsed*self.slowdown.x * (self.speed.x<0 and 1 or -1) );
		if signs.x ~= (self.speed.x > 0 and 1 or -1) then self.speed.x = 0 end;
	end

	if( self.goUp ~= self.goDown ) then
		self.speed.y = self.speed.y + ( elapsed*self.acceleration.y * (self.goUp==true and -1 or 1) );
		if(math.abs(self.speed.y) > self.maxSpeed.y) then self.speed.y = self.maxSpeed.y*signs.y end;
	elseif self.speed.y ~= 0 then
		self.speed.y = self.speed.y + ( elapsed*self.slowdown.y * (self.speed.y<0 and 1 or -1) );
		if signs.y ~= (self.speed.y > 0 and 1 or -1) then self.speed.y = 0 end;
	end
	self.moveObject( self.speed.x*elapsed, self.speed.y*elapsed );
end

--------------------------------------------------------------------------------
-- KeyPressed callback
-- @param key : string Key code
-- @param unicode : number Unicode char value
--------------------------------------------------------------------------------
function XYMover:keyPressed (key, unicode)
	local camKeys = self.controls;
	if     key == camKeys.goUp    then self.goUp    = true; return;
	elseif key == camKeys.goDown  then self.goDown  = true; return;
	elseif key == camKeys.goLeft  then self.goLeft  = true; return;
	elseif key == camKeys.goRight then self.goRight = true; return;
	end
end

--------------------------------------------------------------------------------
-- KeyPressed callback
--------------------------------------------------------------------------------
function XYMover:keyReleased (key)
	local camKeys = self.controls;
	if     key == camKeys.goUp    then self.goUp    = false; return;
	elseif key == camKeys.goDown  then self.goDown  = false; return;
	elseif key == camKeys.goLeft  then self.goLeft  = false; return;
	elseif key == camKeys.goRight then self.goRight = false; return;
	end
end

end
