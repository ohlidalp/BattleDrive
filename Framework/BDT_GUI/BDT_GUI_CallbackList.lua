--------------------------------------------------------------------------------
-- @class table
-- @name class CallbackList
-- @description Keeps a list of executable values for a given sheet event.
-- @field list Table; The list of callable values.
-- @field sheet Table(Sheet); The Sheet object this callback list belongs to
--------------------------------------------------------------------------------

local CallbackList = {};
CallbackList.__index = CallbackList;

--------------------------------------------------------------------------------
-- Adds a value "fn" in the list
-- @param fn Either a function or a table with "run" method; When executed, the value gets the sheet as argument.
-- @return the associated sheet (to allow chaining operations)
--------------------------------------------------------------------------------
function CallbackList:add( fn )
	if isInstanceOfRunnable(fn) or type(fn)=="function"
	then
		table.insert( self.list, 1, fn );
		return self.sheet;
	else
		error("<CallbackList::add> invalid parameter: "..tostring(fn));
	end
end;

--------------------------------------------------------------------------------
-- Removes a value "fn" from the list
-- @return boolean True if the object was removed, false if not found
--------------------------------------------------------------------------------
function CallbackList:remove( fn )
	for index, func in ipairs(self.list) do
		if( func == fn ) then
			table.remove( self.list, index );
			return true;
		end;
	end;
	return false;
end;

--------------------------------------------------------------------------------
-- Executes all values in the order they were added; Each executed value recieves the sheet as argument
-- @return Table(Sheet); The associated sheet (to allow chaining operations)
--------------------------------------------------------------------------------
function CallbackList:call()
	for index, val in ipairs(self.list) do
		if type(val)=="table" then -- It's a table with "run" method.
			val:run(self.sheet);
		else -- It's a function
			val( self.sheet );
		end
	end;
	return self.sheet;
end;

--------------------------------------------------------------------------------
-- Fetches a list of registered handlers
-- @return table List of callbacks.
--------------------------------------------------------------------------------
function CallbackList:getList()
	return self.list;
end

--------------------------------------------------------------------------------
-- Constructs a new CallbackList object.
-- @param _sheet Table: The sheet to attach CallbackList to.
-- @return The CallbackList object.
--------------------------------------------------------------------------------
newCallbackList = function( _sheet )
	return setmetatable(
	{
		list = {};
		sheet = _sheet;
	},
	CallbackList
	);
end;

return newCallbackList;
