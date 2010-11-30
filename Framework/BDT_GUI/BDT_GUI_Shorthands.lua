-- mod_test_bdguix
-- experimental features of bdgui

return function(bd, bdgui) -- enclosing function

local bdgx = {};

function bdgx.openEquippedWindow( desk, _x, _y, _w, _h, resizerScale )
	local window = bdgui.draw.sheet(desk:newSheet( _x, _y, _w, _h )
		.onDrag:add(bdgui.drag.moveSheet));
	resizerScale = resizerScale or 0.5;
	local function resizerOffset( size )
		return ( (size-(size*resizerScale))/2 );
	end;
	window.buttons = {
		-- Edges
		l = bdgui.draw.sheet( window:newSheet(0, resizerOffset(_h) ,10,_h*resizerScale,
				bdgui.arrange.custom(
					bdgui.arrange.x.fixedPosAndScale,
					bdgui.arrange.y.relativePosAndScale))
				.onDrag:add(bdgui.drag.scaleParentL) );
		r = bdgui.draw.sheet( window:newSheet(_w-10, resizerOffset(_h) ,10,_h*resizerScale,
				bdgui.arrange.custom(
					bdgui.arrange.x.fixedPosAndScale,
					bdgui.arrange.y.relativePosAndScale),nil,bdgui.edges.RIGHT)
				.onDrag:add(bdgui.drag.scaleParentR) );
		t = bdgui.draw.sheet( window:newSheet( resizerOffset(_w) ,0,_w*resizerScale,10,
				bdgui.arrange.custom(
					bdgui.arrange.x.relativePosAndScale,
					bdgui.arrange.y.fixedPosAndScale
				))
				.onDrag:add(bdgui.drag.scaleParentT) );
		b = bdgui.draw.sheet( window:newSheet( resizerOffset(_w) ,_h-10,_w*resizerScale,10,
				bdgui.arrange.custom(
					bdgui.arrange.x.relativePosAndScale,
					bdgui.arrange.y.fixedPosAndScale
				),bdgui.edges.BOTTOM,bdgui.edges.RIGHT)
				.onDrag:add(bdgui.drag.scaleParentB) );
		close = bdgui.draw.sheet(
				window:newSheet( _w-40, 0, 20,10 , -- Scale
				bdgui.arrange.custom( -- Arangement
					bdgui.arrange.x.relativePosFixedScale,
					bdgui.arrange.y.fixedPosAndScale),	
				bdgui.edges.TOP, bdgui.edges.RIGHT )); -- Anchoring	
	
		-- Corners
		tl = bdgui.draw.sheet( window:newSheet(0,0,10,10,
				bdgui.arrange.fixedPosAndScale)
				.onDrag:add(bdgui.drag.scaleParentTL) );
		tr = bdgui.draw.sheet( window:newSheet(_w-10,0,10,10,
				bdgui.arrange.fixedPosAndScale,nil,bdgui.edges.RIGHT)
				.onDrag:add(bdgui.drag.scaleParentTR) );
		bl = bdgui.draw.sheet( window:newSheet(0,_h-10,10,10,
				bdgui.arrange.fixedPosAndScale,bdgui.edges.BOTTOM,nil)
				.onDrag:add(bdgui.drag.scaleParentBL) );
		br = bdgui.draw.sheet( window:newSheet(_w-10,_h-10,10,10,
				bdgui.arrange.fixedPosAndScale,bdgui.edges.BOTTOM,bdgui.edges.RIGHT)
				.onDrag:add(bdgui.drag.scaleParentBR) );
		
	};
	function window.buttons.close:drawContent()
		love.graphics.line(
				self.absolutePos.x, 
				self.absolutePos.y, 
				self.absolutePos.x+self.w,
				self.absolutePos.y+self.h);
		love.graphics.line(
				self.absolutePos.x, 
				self.absolutePos.y+self.h, 
				self.absolutePos.x+self.w,
				self.absolutePos.y);
	end;
	return window;
end;

function bdgx.richDraw_Clos( sheet, drawContentFunction )
	if( type(drawContentFunction)~="function" ) then
		drawContentFunction = nil;
	end;
	return function(self)
		-- Choose colors
		local fillColor, lineColor;
		local palette = #self.sheets>0 and bdgui.draw.colors.page or bdgui.draw.colors.label;
		if( self.active==true ) then
			if( self.mouseIsOver==true ) then
				if( self.mouseIsDown==true ) then
					fillColor = palette.mousedownFill;
					lineColor = palette.mousedownOutline;
				else
					fillColor = palette.mouseoverFill;
					lineColor = palette.mouseoverOutline;
				end;
			else
				fillColor = palette.fill;
				lineColor = palette.outline;
			end;
		else
			fillColor = palette.inactiveFill;
			lineColor = palette.inactiveOutline;
		end;
		
		-- Draw
		love.graphics.setLineStyle( love.line_rough );
		love.graphics.setColor(fillColor);
		love.graphics.polygon( love.draw_fill, self:getCorners(offsetX, offsetY) );
		if( drawContentFunction~=nil ) then drawContentFunction(self); end;
		love.graphics.setColor(lineColor);
		love.graphics.polygon( love.draw_line, self:getCorners(offsetX, offsetY) );
		
		-- Draw child sheets
		for index, sheet in ipairs(self.sheets) do
			sheet:draw();
		end;
	end;
end;

function bdgx.closeWindow( self )
	self.parent:removeSheet(self);
end;

function bdgx.makeLabel(sheet)
	
end;

return bdgx;

end; -- end of enclosing function