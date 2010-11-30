-- Treats x and y axes differently. This is necessary because graphics
-- are viewed under 45degrees angle, thus y axis has shorter distances than x axis.
return function(BDT_Common){
local MapConverter = {};
MapConverter.__index = MapConverter;

-- Transforms a vector of pixels into vector of b2Meters.
-- arguments must be in <x, y, x, y, x...> alignment and the first element must be X!
function MapConverter:pixelsToB2Meters(...)
	--if type(self) ~= "table" then error("Converter:pixelsToB2Meters: invalid self argument") end;
	local values = {...};
	local Y = false;
	for index, value in ipairs(values) do
		if Y then
			Y=false;
			values[index] = value*self.b2MetersInPixel_Y;
		else
			values[index] = value*self.b2MetersInPixel_X;
			Y=true;
		end;
	end;
	return unpack(values);
end;
-- Transforms a vector of b2Meters into vector of pixels.
-- arguments must be in <x, y, x, y, x...> alignment and the first element must be X!
function MapConverter:b2MetersToPixels(...)
	--if type(self) ~= "table" then error("Converter:b2MetersToPixels: invalid self argument") end;
	local values = {...};
	local Y=false;
	for index, value in ipairs(values) do
		if Y then
			Y=false;
			values[index] = value/self.b2MetersInPixel_Y;
		else
			values[index] = value/self.b2MetersInPixel_X;
			Y=true;
		end;
	end;
	return unpack(values);
end;

function INTERFACE.newMapConverter( _b2MetersInPixel_X, _b2MetersInPixel_Y )
	return setmetatable(
		{
			b2MetersInPixel_X = _b2MetersInPixel_X or 0.02;
			b2MetersInPixel_Y = _b2MetersInPixel_Y or 0.02/0.7;
		},
		MapConverter
	);
end;
}
