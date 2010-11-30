-- This file is a part of BD-GUI project.
--bdgui_util

return function( bdgui ) -- Enclosing function

------------------------ Dragging and scaling sheets ---------------------------
bdgui.drag = {};

---- Scaling the sheet by HV corner ----
-- Bottom right
bdgui.drag.scaleBR = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( mouseNewX - mouseOldX,mouseNewY - mouseOldY,
			self.anchor.vertical,self.anchor.horizontal);
end;
-- Top left
bdgui.drag.scaleTL = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( mouseOldX - mouseNewX,mouseOldY - mouseNewY,
			self.anchor.vertical,self.anchor.horizontal);
end;
-- Top right
bdgui.drag.scaleTR = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( mouseNewX-mouseOldX  ,mouseOldY-mouseNewY,
			self.anchor.vertical,self.anchor.horizontal);
end;
-- Bottom left
bdgui.drag.scaleBL = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( mouseOldX - mouseNewX,mouseNewY - mouseOldY,
			self.anchor.vertical,self.anchor.horizontal);
end;

---- Scaling the parent sheet by HV corner using HV anchored child sheet ----
-- Bottom right
bdgui.drag.scaleParentBR = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	--print("<scaleParentBR> new x,y old x, y:",mouseNewX, mouseNewY, mouseOldX, mouseOldY);
	self.parent:resize( mouseNewX - mouseOldX,mouseNewY - mouseOldY,
			self.anchor.vertical,self.anchor.horizontal);
end;
-- Top left
bdgui.drag.scaleParentTL = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( mouseOldX - mouseNewX,mouseOldY - mouseNewY,
			self.anchor.vertical,self.anchor.horizontal);
end;
-- Top right
bdgui.drag.scaleParentTR = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( mouseNewX-mouseOldX  ,mouseOldY-mouseNewY,
			self.anchor.vertical,self.anchor.horizontal);
end;
-- Bottom left
bdgui.drag.scaleParentBL = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( mouseOldX - mouseNewX,mouseNewY - mouseOldY,
			self.anchor.vertical,self.anchor.horizontal);
end;

---- Scaling the sheet by H/V edge. ----
function bdgui.drag.scaleL( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( mouseOldX - mouseNewX,0,self.anchor.vertical,nil);
end;

function bdgui.drag.scaleR( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( mouseNewX - mouseOldX,0,self.anchor.vertical,0);
end;

function bdgui.drag.scaleT( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( 0,mouseOldY-mouseNewY,	nil,self.anchor.horizontal);
end;

function bdgui.drag.scaleB( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:resize( 0,mouseNewY - mouseOldY,nil,self.anchor.horizontal);
end;

---- Scaling the sheet by H/V edge using H/V anchored child sheet ----
function bdgui.drag.scaleParentL( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( mouseOldX - mouseNewX,0,self.anchor.vertical,nil);
end;

function bdgui.drag.scaleParentR( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( mouseNewX - mouseOldX,0,self.anchor.vertical,0);
end;

function bdgui.drag.scaleParentT( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( 0,mouseOldY-mouseNewY,	nil,self.anchor.horizontal);
end;

function bdgui.drag.scaleParentB( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:resize( 0,mouseNewY - mouseOldY,nil,self.anchor.horizontal);
end;

---- Dragging sheets ----
-- Drag sheet
bdgui.drag.moveSheet = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self:move( mouseNewX-mouseOldX, mouseNewY-mouseOldY );
end;

-- Drag parent sheet
bdgui.drag.moveParent = function( self, mouseNewX, mouseNewY, mouseOldX, mouseOldY )
	self.parent:move( mouseNewX-mouseOldX, mouseNewY-mouseOldY );
end;

end;