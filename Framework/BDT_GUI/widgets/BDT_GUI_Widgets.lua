--- @package BDT_GUI

-- Convenience functions for quick work.
--

--module("BDT_GUI.BDT_GUI_Widgets");

return function(BDT_GUI, dir) -- enclosing function

local widgets = {};

--------------------------------------------------------------------------------
-- Creates panel with dragging and resizing equipment.
-- Note: created panel is not attached
-- @class function
-- @name BDT_GUI.widgets.newScalingWindow
-- @return Sheet The panel
--------------------------------------------------------------------------------


function widgets.newScalingWindow( x, y, w, h, borderW, scalerSize, barW )
	local checkArg = BDT.checkArg;
	local fName = "BDT_GUI.arrange.openEquippedWindow"
	checkArg(fName, "x", x, "number");
	checkArg(fName, "y", y, "number");
	checkArg(fName, "w", w, "number");
	checkArg(fName, "h", h, "number");

	local BDT_GUI = BDT_GUI;
	local arrange = BDT_GUI.arrangement;
	local panel = BDT_GUI.newSheet( x, y, w, h );
	panel:setActive(false);
	panel.renderer = BDT_GUI.newSheetRenderer(panel);
	scalerSize = scalerSize or 0.5;
	borderW = borderW or 10;
	local function resizerOffset( size )
		return ( (size-(size*scalerSize))/2 );
	end
	panel.buttons = {
		-- Edges
		l = panel:newSheet(0, borderW ,borderW, h - 2 * borderW,
				arrange.custom(
					arrange.x.fixedPosAndScale,
					arrange.y.fixedPosRelativeScale));
		r = panel:newSheet(w-10, resizerOffset(h) ,10,h*scalerSize,
				arrange.custom(
					arrange.x.fixedPosAndScale,
					arrange.y.relativePosAndScale),nil,BDT_GUI.edges.RIGHT);
		t =  panel:newSheet( resizerOffset(w) ,0,w*scalerSize,10,
				arrange.custom(
					arrange.x.relativePosAndScale,
					arrange.y.fixedPosAndScale));
		b =  panel:newSheet( resizerOffset(w) ,h-10,w*scalerSize,10,
				arrange.custom(
					arrange.x.relativePosAndScale,
					arrange.y.fixedPosAndScale
				),BDT_GUI.edges.BOTTOM,BDT_GUI.edges.RIGHT);
		close =
				panel:newSheet( w-40, 0, 20,10 , -- Scale
				arrange.custom( -- Arangement
					arrange.x.relativePosFixedScale,
					arrange.y.fixedPosAndScale),
				BDT_GUI.edges.TOP, BDT_GUI.edges.RIGHT ); -- Anchoring

		-- Corners
		tl =  panel:newSheet(0,0,10,10,arrange.fixedPosAndScale);
		tr =  panel:newSheet(w-10,0,10,10,
				arrange.fixedPosAndScale,nil,BDT_GUI.edges.RIGHT);
		bl =  panel:newSheet(0,h-10,10,10,
				arrange.fixedPosAndScale,BDT_GUI.edges.BOTTOM,nil);
		br =  panel:newSheet(w-10,h-10,10,10,
				arrange.fixedPosAndScale,BDT_GUI.edges.BOTTOM,BDT_GUI.edges.RIGHT);

	};
	panel.buttons.l.onDrag:add(BDT_GUI.drag.scaleParentL);
	panel.buttons.r.onDrag:add(BDT_GUI.drag.scaleParentR);
	panel.buttons.t.onDrag:add(BDT_GUI.drag.moveParent);
	panel.buttons.b.onDrag:add(BDT_GUI.drag.scaleParentB);
	panel.buttons.tl.onDrag:add(BDT_GUI.drag.scaleParentTL)
	panel.buttons.tr.onDrag:add(BDT_GUI.drag.scaleParentTR)
	panel.buttons.bl.onDrag:add(BDT_GUI.drag.scaleParentBL)
	panel.buttons.br.onDrag:add(BDT_GUI.drag.scaleParentBR)

	for _, sheet in pairs(panel.buttons) do
		BDT_GUI.newSheetRenderer(sheet);
	end

	return panel;
end

BDT_GUI.widgets = widgets;

function BDT_GUI.widgets.newWindow(x, y, w, h, barW, borderW, closeW, render)
	barW = barW or 20;
	borderW = borderW or 5;
	closeW = closeW or 30;
	local win = BDT_GUI.newSheet( x, y, w, h );
	win:setActive(false);
	local bar = win:newSheet(0 + borderW, 0, w - (closeW + 2 * borderW), barW,
			BDT_GUI.arrangement.custom(
				BDT_GUI.arrangement.x.fixedPosLinkedScale,
				BDT_GUI.arrangement.y.fixedPosAndScale));
	bar.onDrag:add(BDT_GUI.drag.moveParent);
	local close = win:newSheet(w - (closeW + borderW), 0, closeW, barW,
			nil, BDT_GUI.edges.TOP, BDT_GUI.edges.RIGHT);
	close.onMouseDown:add(function() win:detach() end);
	local panel = win:newSheet(borderW, barW, w - (borderW * 2), h - (borderW + barW));
	local tlScaler = win:newSheet(0, 0, borderW, barW);
	tlScaler.onDrag:add(BDT_GUI.drag.scaleParentTL);
	local trScaler = win:newSheet(w - borderW, 0, borderW, barW,
			BDT_GUI.arrangement.fixedPosAndScale, BDT_GUI.edges.TOP, BDT_GUI.edges.RIGHT);
	trScaler.onDrag:add(BDT_GUI.drag.scaleParentTR);
	local blScaler = win:newSheet(0, h - borderW, borderW, borderW,
			nil, BDT_GUI.edges.BOTTOM, BDT_GUI.edges.LEFT);
	blScaler.onDrag:add(BDT_GUI.drag.scaleParentBL);
	local brScaler = win:newSheet(w - borderW, h - borderW, borderW, borderW,
			nil, BDT_GUI.edges.BOTTOM, BDT_GUI.edges.RIGHT);
	brScaler.onDrag:add(BDT_GUI.drag.scaleParentBR);
	local lScaler = win:newSheet(0, barW, borderW, h - (borderW + barW), h - (barW + borderW),
			BDT_GUI.arrangement.custom(
				BDT_GUI.arrangement.x.fixedPosAndScale,
				BDT_GUI.arrangement.y.fixedPosLinkedScale),
			BDT_GUI.edges.TOP, BDT_GUI.edges.LEFT);
	lScaler.onDrag:add(BDT_GUI.drag.scaleParentL);
	local rScaler = win:newSheet(w - borderW, barW, borderW, h - (barW + borderW),
			BDT_GUI.arrangement.custom(
				BDT_GUI.arrangement.x.fixedPosAndScale,
				BDT_GUI.arrangement.y.fixedPosLinkedScale),
			BDT_GUI.edges.TOP, BDT_GUI.edges.RIGHT);
	rScaler.onDrag:add(BDT_GUI.drag.scaleParentR);
	local bScaler = win:newSheet(borderW, h - borderW, w - (2 * borderW), borderW,
			BDT_GUI.arrangement.custom(
				BDT_GUI.arrangement.x.fixedPosLinkedScale,
				BDT_GUI.arrangement.y.fixedPosAndScale),
			BDT_GUI.edges.BOTTOM, BDT_GUI.edges.LEFT);
	bScaler.onDrag:add(BDT_GUI.drag.scaleParentB);
	if render == nil then render = true end
	if render then
		local r = BDT_GUI.newSheetRenderer;
		r(win);
		r(bar);
		r(close);
		r(tlScaler);
		r(trScaler);
		r(brScaler);
		r(blScaler);
		r(lScaler);
		r(rScaler);
		r(bScaler);
	end
	return win, panel;
end

end -- end of enclosing function