--
-- Convenience functions for quick work.
--

return function(BDT_GUI) -- enclosing function

local shorthands = {};

--------------------------------------------------------------------------------
-- Creates windows with dragging and resizing equipment.
-- Note: created window is not attached
-- @class function
-- @name BDT_GUI.shorthands.openEquippedWindow
-- @return Window
--------------------------------------------------------------------------------


function shorthands.openEquippedWindow( _x, _y, _w, _h, resizerScale )
	local BDT_GUI = BDT_GUI;
	local arrange = BDT_GUI.arrangement;
	local window = BDT_GUI.newSheet( _x, _y, _w, _h );
	window.onDrag:add(BDT_GUI.drag.moveSheet);
	resizerScale = resizerScale or 0.5;
	local function resizerOffset( size )
		return ( (size-(size*resizerScale))/2 );
	end;
	window.buttons = {
		-- Edges
		l = window:newSheet(0, resizerOffset(_h) ,10,_h*resizerScale,
				arrange.custom(
					arrange.x.fixedPosAndScale,
					arrange.y.relativePosAndScale));
		r = window:newSheet(_w-10, resizerOffset(_h) ,10,_h*resizerScale,
				arrange.custom(
					arrange.x.fixedPosAndScale,
					arrange.y.relativePosAndScale),nil,BDT_GUI.edges.RIGHT);

		t =  window:newSheet( resizerOffset(_w) ,0,_w*resizerScale,10,
				arrange.custom(
					arrange.x.relativePosAndScale,
					arrange.y.fixedPosAndScale));

		b =  window:newSheet( resizerOffset(_w) ,_h-10,_w*resizerScale,10,
				arrange.custom(
					arrange.x.relativePosAndScale,
					arrange.y.fixedPosAndScale
				),BDT_GUI.edges.BOTTOM,BDT_GUI.edges.RIGHT);

		close =
				window:newSheet( _w-40, 0, 20,10 , -- Scale
				arrange.custom( -- Arangement
					arrange.x.relativePosFixedScale,
					arrange.y.fixedPosAndScale),
				BDT_GUI.edges.TOP, BDT_GUI.edges.RIGHT ); -- Anchoring

		-- Corners
		tl =  window:newSheet(0,0,10,10,arrange.fixedPosAndScale);
		tr =  window:newSheet(_w-10,0,10,10,
				arrange.fixedPosAndScale,nil,BDT_GUI.edges.RIGHT);
		bl =  window:newSheet(0,_h-10,10,10,
				arrange.fixedPosAndScale,BDT_GUI.edges.BOTTOM,nil);
		br =  window:newSheet(_w-10,_h-10,10,10,
				arrange.fixedPosAndScale,BDT_GUI.edges.BOTTOM,BDT_GUI.edges.RIGHT);

	};
	window.buttons.l.onDrag:add(BDT_GUI.drag.scaleParentL);
	window.buttons.r.onDrag:add(BDT_GUI.drag.scaleParentR);
	window.buttons.t.onDrag:add(BDT_GUI.drag.scaleParentT);
	window.buttons.b.onDrag:add(BDT_GUI.drag.scaleParentB);
	window.buttons.tl.onDrag:add(BDT_GUI.drag.scaleParentTL)
	window.buttons.tr.onDrag:add(BDT_GUI.drag.scaleParentTR)
	window.buttons.bl.onDrag:add(BDT_GUI.drag.scaleParentBL)
	window.buttons.br.onDrag:add(BDT_GUI.drag.scaleParentBR)

	return window;
end

BDT_GUI.shorthands = shorthands;

end -- end of enclosing function