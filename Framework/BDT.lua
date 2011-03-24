local BDT={
	BDT_Dir = "",
	false,false,false,false
};

function BDT:init(BDT_Dir)
	self.BDT_Dir = BDT_Dir; -- Without slash
	self._BDT_Dir = BDT_Dir;
	self._loaded = {};
end

function BDT:loadLibrary(libName)
	if not self._loaded[libName] then
		local libDir = self._BDT_Dir.."/BDT_"..libName;
		local libFile = libDir.."/BDT_"..libName..".lua";
		local lib = require(libFile) (libDir, self);
		self._loaded[libName] = lib;
		return lib;
	end
	return self._loaded[libName];
end

--------------------------------------------------------------------------------
-- Checks if the two entered AABBs (Axis-Aligned Bounding Boxes) overlap.
--------------------------------------------------------------------------------
function BDT.aabbsOverlap(ax1,ay1,ax2,ay2,  bx1,by1,bx2,by2)
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
end

--------------------------------------------------------------------------------
-- Removes element(s) from table
-- @param value mixed The object to be removed from table
-- @param all boolean True if all occurences of given object should be removed, false if only the first occurence should be removed.
-- @return boolean True if anything was deleted.
--------------------------------------------------------------------------------
function BDT.tableRemoveByValue( t, value, all )
	all = all or false;
	local removed = 0;
	for index, element in pairs(t) do
		if( element==value ) then
			table.remove( t, index );
			removed = removed + 1;
			if(not all) then return true end;
		end;
	end;
	return removed>0;
end;

--------------------------------------------------------------------------------
-- Checks if table has given set of functions
--------------------------------------------------------------------------------
function BDT.isTableAndHasFunctions(t,...)
	--[[ #DBG#
		print("IN BDT_GUI._isTableAndHasFunctions(), t:["..tostring(t).."], #t:"..(type(t)=="table" and tostring(#t) or "NOT-A-TABLE")..", arg:"..table.concat(arg,' '));
	--]]
	if t==nil or type(t)~="table" then
		return false;
	end
	for i,fieldName in ipairs(arg) do
		local value = t[fieldName];
		--[[ #DBG#
			print("\tfield:"..fieldName.." value:"..tostring(value));
		--]]
		if value==nil or type(value)~="function" then
			return false;
		end
	end
	return true;
end

--------------------------------------------------------------------------------
-- Check a mandatory argument of a function; raise an error() and print message if check fails.
-- @param fName string Function name (for error message)
-- @param argname string Argument name (for error message)
-- @param val mixed The value to check.
-- @param reqType string The required data type.
--------------------------------------------------------------------------------
function BDT.checkArg(fName,argName,val,reqType)
	if type(val)~=reqType then
		error("ERROR: "..fName.."(): Invalid argument '"..argName.."', expected "..reqType..", got ["..tostring(val).."]");
	end
end

--------------------------------------------------------------------------------
-- Check that a mandatory argument of a function is an instance of specified class; raise an error() and print message if check fails.
-- @param fName string Function name (for error message)
-- @param argname string Argument name
-- @param val mixed The value to check.
-- @param checkerFn string A function which checks the object type; It accepts a single argument (the object) and returns boolean.
-- @param className string Name of the desired class (for error message). Optional.
--------------------------------------------------------------------------------
function BDT.checkArgInstanceOf(fName,argName,val,checkerFn,className)
	if not checkerFn(val) then
		local errMsg = "ERROR: "..fName.."(): Invalid argument '"..argName.."', got '"..BDT.toString(val).."'";
		if className~=nil then
			errMsg = errMsg..", expected '"..className.."'";
		end
		error(errMsg);
	end
end

--------------------------------------------------------------------------------
-- Check that a mandatory argument of a function is not nil; raise an error() and print message if check fails.
-- @param fName string Function name (for error message)
-- @param argname string Argument name (for error message)
-- @param val mixed The value to check.
--------------------------------------------------------------------------------
function BDT.checkArgNotNil(fName,argName,val)
	if val==nil then
		error("ERROR: "..fName.."(): Missing argument '"..argName.."'");
	end
end

--------------------------------------------------------------------------------
-- Returns string description of supplied variable; Uses object's 'toString' method if there's one.
-- @param o mixed the data to describe.
--------------------------------------------------------------------------------
function BDT.toString(o)
	if type(o)=="table" and type(o.toString)=="function" then
		return o:toString();
	else
		return tostring(o);
	end
end

--------------------------------------------------------------------------------
-- Checks presence and data type of given field; prints following error message on failure:
-- @param t table Required.
-- @param index mixed Field name/index
-- @param reqType string
-- @param errMsg string Custom part of the error message
-- @return boolean True if the field exists and has right data type, or false if not.
--------------------------------------------------------------------------------
function BDT.checkField(t,index,reqType,errMsg)
	BDT.checkArg("BDT.checkField","t",t,"table");
	BDT.checkArgNotNil("BDT.checkField","index",index);
	BDT.checkArg("BDT.checkField","reqType",reqType,"string");
	local v = t[index];
	if v==nil then
		print("WARNING: "..errMsg.." missing field '"..tostring(index).."'");
		return false;
	elseif type(v)~=reqType then
		print("WARNING: "..errMsg.." invalid field '"..tostring(index).."', expected '"..reqType.."'" );
		return false;
	else
		--[[--#DBG#
			print("DBG BDT.checkField(): errMsg:"..errMsg..", field '"..tostring(index).."', expected '"..reqType.."' OK" );--]]
		return true;
	end
end

return BDT;

