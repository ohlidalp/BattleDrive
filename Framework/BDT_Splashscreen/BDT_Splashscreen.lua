--[[

--]]

local Splashscreen = {};
Splashscreen.__index = Splashscreen;
local love = love;
local love_graphics = love.graphics;
local newColor = love_graphics.newColor;

-- Configuration
local config = {
	statusbarBgColor = newColor(50, 200, 100);
	statusbarColor = newColor(200,200,100);
	bgColor = newColor(50,50,50);
	statusbarH = 10,
	statusbarPadding = 3,
	captionColor = newColor(150,150,150);
	statusTextColor = newColor(0,0,0);
	fileTextColor = newColor(0,0,0);
};

local PUBLIC = {};

function PUBLIC.newSplashscreen(x, y, w, h, caption, reversible, captionFont, statusFont, fileFont )
	local captionPadding = 10;
	local statusbarFullH = (config.statusbarPadding*2+config.statusbarH);
	return setmetatable({
		-- Atrributes
		x = x,
		y = y,
		w = w,
		h = h,
		reversible = reversible or true,
		bgColor = config.bgColor;
		-- Status bar
		statusbarBgColor = config.statusbarBgColor;
		statusbarColor = config.statusbarColor;
		statusbarH = config.statusbarH,
		statusbarPadding = config.statusbarPadding;
		-- Splashscreen caption
		captionText = caption or "Loading...",
		captionFont = captionFont or love_graphics.getFont();
		captionColor = config.captionColor;
		captionX = 10,
		captionY = ((h/5)*3)-statusbarFullH,
		captionAlign = love.align_center;
		captionLimit = w-20,
		-- Text with currently loaded file name. (second line)
		fileText = "",
		fileTextFont = fileFont or love_graphics.getFont();
		fileTextX = 10;
		fileTextY = h-statusbarFullH;
		fileTextLimit = w-20;
		fileTextColor = config.fileTextColor;
		-- Text describing process status (first line)
		statusText = "",
		statusTextFont = statusFont or love_graphics.getFont();
		statusTextColor = config.statusTextColor;
		statusTextY = (h-statusbarFullH)-15;
		statusTextX = 10;
		statusTextLimit = w-20;
		-- Initialization
		percentage = 0,
	},Splashscreen);
end

function Splashscreen:draw()
	-- Optimize
	local love = love;
	local graphics = love.graphics;
	local setColor = graphics.setColor;
	local rectangle = graphics.rectangle;
	local draw_fill = love.draw_fill;
	local drawf = graphics.drawf;
	local setFont = graphics.setFont;
	local splashX, splashY, splashW = self.x, self.y, self.w;
	local statusbarFullHeight = self.statusbarH+2*self.statusbarPadding;

	-- Draw panel
	setColor(self.bgColor);
	rectangle( draw_fill, splashX, splashY, splashW, self.h );

	-- Draw statusbar panel
	setColor(self.statusbarBgColor);
	rectangle( draw_fill, splashX, splashY+self.h, splashW, statusbarFullHeight );

	-- Draw statusbar
	setColor(self.statusbarColor);
	rectangle( draw_fill, splashX+self.statusbarPadding, splashY+self.statusbarPadding,
		((splashW-self.statusbarPadding*2)/100)*self.percentage, self.statusbarH );

	-- Draw caption
	setColor(self.captionColor);
	setFont(self.captionFont);
	drawf(self.captionText, self.captionX+self.x, self.captionY+self.y, self.captionLimit, self.captionAlign);

	-- Draw status text
	setColor(self.statusTextColor);
	setFont(self.statusTextFont);
	drawf(self.statusText, splashX+self.statusTextX, splashY+self.statusTextY,
		splashW-self.statusTextX*2, love.align_left )

	-- Draw file text
	setColor(self.fileTextColor);
	setFont(self.fileTextFont);
	drawf(self.fileText, splashX+self.fileTextX, splashY+self.fileTextY, splashW-self.statusTextX*2);
end

function Splashscreen:setFileText(fileText)
	self.fileText = tostring(fileText);
end

function Splashscreen:setStatusText(statusText)
	self.statusText = tostring(statusText)
end

function Splashscreen:setPercentage(percentage)
	if type(percentage)~="number" then
		error("<Splashscreen:setPercentage> Invalid argument #1 'percentage':"
			.."number expected, got "..type(percentage));
	end
	if not self.reversible and percentage<self.percentage then
		return;
	else
		if percentage>100 then
			self.percentage = 100;
		elseif percentage<0 then
			self.percentage = 0;
		else
			self.percentage = percentage;
		end
	end
end

function Splashscreen:setupCaption(text, color, x, y, limit, align, font)
	self.captionText = text;
	self.captionColor = color;
	self.captionX = x;
	self.captionY = y;
	self.captionLimit = limit;
	self.captionAlign = align;
	self.captionFont = font;
end

return PUBLIC;