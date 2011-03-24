return function (BDT_GUI, dir)

BDT_GUI.StatusMarker = class("BDT_GUI.StatusMarker");

function BDT_GUI.StatusMarker:initialize()
	-- Loading status display data.
	self.doneColor = {20,200,20,255}
	self.normColor = {255,255,255,255}
	self.labelX = 50;
	self.doneX = 300;
	self.yPos = 100;
	self.yStep = 15;
	self.lastTime=0;
end

function BDT_GUI.StatusMarker:printLabel(msg)
	love_graphics_print(msg, self.labelX, self.yPos);
	love_graphics_present();
end

function BDT_GUI.StatusMarker:printTime()
	love_graphics_setColor(
		self.doneColor[1], self.doneColor[2], self.doneColor[3], self.doneColor[4]);
	local t = love_timer_getTime()
	love_graphics_print(t - self.lastTime .. " sec", self.doneX, self.yPos);
	self.lastTime = t;
	love_graphics_setColor(
		self.normColor[1], self.normColor[2], self.normColor[3], self.normColor[4]);
	self.yPos = self.yPos + self.yStep;
	love_graphics_present();
end

function BDT_GUI.StatusMarker:resetTime()
	self.lastTime = love_timer_getTime();
end

end
