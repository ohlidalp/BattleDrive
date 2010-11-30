return function(BDT_Common_Dir)
local math_pi = math.pi;
local math_atan2 = math.atan2;
local BDT_Common = {

	rectanglesOverlap = function( x1,y1,w1,h1,  x2,y2,w2,h2 )
		return
			-- x collision
			( x1+w1 > x2+w2
				and (x1+w1)-x2 < w1+w2
				or (x2+w2)-x1 < w1+w2 )
			and
			-- y collision
			( y1+h1 > y2+h2
				and (y1+h1)-y2 < h1+h2
				or (y2+h2)-y1 < h1+h2 );
	end;

	aabbsOverlap = function(ax1,ay1,ax2,ay2,  bx1,by1,bx2,by2)
		return
			-- x collision
			( ax2 > bx2
				and (bx2>=ax1 and bx2<=ax2)
				or  (ax2>=bx1 and ax2<=bx2) )
			and
			-- y collision
			( ay2 > by2
				and (by2>=ay1 and by2<=ay2)
				or  (ay2>=by1 and ay2<=by2) );
	end;

	vectorLength = function( x, y, angle )
		if( x==0 ) then
			return math.abs(y)
		elseif( y==0 ) then
			return math.abs(x)
		else
			return math.abs(y/math.sin(angle));
		end;
	end;
--------------------------------------------------------------------------------
-- Computes game system-relevant angle (in radians)
--------------------------------------------------------------------------------
	getSystemAngle = function( x,y )
		local angle = math_atan2(x,y);
		if(angle<0.0)then
			return angle*-1;
		else
			return (math_pi-angle)+math_pi;
		end;
	end;
};

--------------------------------------------------------------------------------
-- Check a mandatory argument of a function; raise an error() and print message if check fails.
-- @param fName string Function name (for error message)
-- @param argname string Argument name (for error message)
-- @param val mixed The value to check.
-- @param reqType string The required data type.
--------------------------------------------------------------------------------
function BDT_Common.checkArg(fName,argIdx,argName,val,reqType)
	if type(val)~=reqType then
		error("ERROR: "..fName.."(): Invalid argument #"..argIdx.." '"..argName
			.."', expected "..reqType..", got ["..tostring(val).."]");
	end
end

--------------------------------------------------------------------------------
-- Loops a table and prints all contents.
-- @param tab string Prefix of every line
-- @param comma string Separator of index:value
-- @param newline string Suffix of every line
-- @return string
--------------------------------------------------------------------------------
function BDT_Common.tableConcat(t, tab, comma, newline)
	if (type(t)~="table") then
		return "";
	end;
	tab = tab or '\t';
	comma = comma or ': ';
	newline = newline or '\n';
	output = "";
	for key, value in pairs(t) do
		if(output ~= "")then
			output=output..newline;
		end;
		output=output..tab..tostring(key)..comma..tostring(value);
	end;
	return output;
end;

return BDT_Common;

end