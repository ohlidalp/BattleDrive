-- Convert pixel coordinates into box2d coordinates.
return function(BDT_Common){
-- Treats x and y coordinates the same.
local LinearConverter = {};
LinearConverter.__index = LinearConverter;

function LinearConverter:pixelsToB2Meters(...)
	--if type(self) ~= "table" then error("Converter:pixelsToB2Meters: invalid self argument") end;
	local values = {...};
	for index, value in ipairs(values) do
		values[index] = value*self.b2MetersInPixel;
	end;
	return unpack(values);
end;

function LinearConverter:b2MetersToPixels(...)
	--if type(self) ~= "table" then error("Converter:b2MetersToPixels: invalid self argument") end;
	local values = {...};
	for index, value in ipairs(values) do
		values[index] = value/self.b2MetersInPixel;
	end;
	return unpack(values);
end;

function BDT_Common.newLinearConverter( _b2MetersInPixel )
	return setmetatable(
		{
			b2MetersInPixel = _b2MetersInPixel or 0.02;
		},
		LinearConverter
	);
end;

}
