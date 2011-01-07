-- This file is a part of BD-GUI project.
--BDT_GUI_util

return function( BDT_GUI ) -- Enclosing function

-- --------------------- Dragging and scaling sheets ---------------------------
BDT_GUI.drag = {};

---- Scaling the sheet by HV corner ----
-- Bottom right
BDT_GUI.drag.scaleBR = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( mouseNewX - mouseOldX,mouseNewY - mouseOldY,
			self.anchor.vertical,self.anchor.horizontal);
end;
-- Top left
BDT_GUI.drag.scaleTL = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( mouseOldX - mouseNewX,mouseOldY - mouseNewY,
			self.anchor.vertical,self.anchor.horizontal);
end;
-- Top right
BDT_GUI.drag.scaleTR = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( mouseNewX-mouseOldX  ,mouseOldY-mouseNewY,
			self.anchor.vertical,self.anchor.horizontal);
end;
-- Bottom left
BDT_GUI.drag.scaleBL = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( mouseOldX - mouseNewX,mouseNewY - mouseOldY,
			self.anchor.vertical,self.anchor.horizontal);
end;

-- -- Scaling the parent sheet by HV corner using HV anchored child sheet -- --
-- Bottom right
BDT_GUI.drag.scaleParentBR = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	--print("<scaleParentBR> new x,y old x, y:",mouseNewX, mouseNewY, mouseOldX, mouseOldY);
	self.parent:resize( mouseNewX - mouseOldX,mouseNewY - mouseOldY,
			self.anchor.vertical,self.anchor.horizontal);
end;
-- Top left
BDT_GUI.drag.scaleParentTL = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( mouseOldX - mouseNewX,mouseOldY - mouseNewY,
			self.anchor.vertical,self.anchor.horizontal);
end;
-- Top right
BDT_GUI.drag.scaleParentTR = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( mouseNewX-mouseOldX  ,mouseOldY-mouseNewY,
			self.anchor.vertical,self.anchor.horizontal);
end;
-- Bottom left
BDT_GUI.drag.scaleParentBL = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( mouseOldX - mouseNewX,mouseNewY - mouseOldY,
			self.anchor.vertical,self.anchor.horizontal);
end;

-- -- Scaling the sheet by H/V edge. -- --
function BDT_GUI.drag.scaleL( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( mouseOldX - mouseNewX,0,self.anchor.vertical,nil);
end;

function BDT_GUI.drag.scaleR( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( mouseNewX - mouseOldX,0,self.anchor.vertical,0);
end;

function BDT_GUI.drag.scaleT( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( 0,mouseOldY-mouseNewY,	nil,self.anchor.horizontal);
end;

function BDT_GUI.drag.scaleB( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( 0,mouseNewY - mouseOldY,nil,self.anchor.horizontal);
end;

-- -- Scaling the sheet by H/V edge using H/V anchored child sheet ----
function BDT_GUI.drag.scaleParentL( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( mouseOldX - mouseNewX,0,self.anchor.vertical,nil);
end;

function BDT_GUI.drag.scaleParentR( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( mouseNewX - mouseOldX,0,self.anchor.vertical,0);
end;

function BDT_GUI.drag.scaleParentT( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( 0,mouseOldY-mouseNewY,	nil,self.anchor.horizontal);
end;

function BDT_GUI.drag.scaleParentB( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( 0,mouseNewY - mouseOldY,nil,self.anchor.horizontal);
end;

-- -- Dragging sheets -- --
-- Drag sheet
BDT_GUI.drag.moveSheet = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:move( mouseNewX-mouseOldX, mouseNewY-mouseOldY );
end;

-- Drag parent sheet
BDT_GUI.drag.moveParent = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:move( mouseNewX-mouseOldX, mouseNewY-mouseOldY );
end;

end;