--[[
________________________________________________________________________________
                      BDT GUI Testbed: Application
--]]

-- three panels , all with corner scalers, the top level has edge scalers
function test1()
	sheets = {};
	sheets.top = gui.draw.sheet(
			desk:newSheet( 100,100,400,400, gui.edges.TOP, gui.edges.LEFT )
				.onDrag:add( gui.drag.moveSheet ));
	sheets.topBtn = {

		-- Edges
		l = gui.draw.sheet(
				sheets.top:newSheet(0,50,20,300,
					gui.arrange.custom(
						gui.arrange.x.fixedPosAndScale,
						gui.arrange.y.relativePosAndScale )
				).onDrag:add(gui.drag.scaleParentL) );
		r = gui.draw.sheet( sheets.top:newSheet(380,50,20,300,
				gui.arrange.custom(
						gui.arrange.x.fixedPosAndScale,
						gui.arrange.y.relativePosAndScale)
					,nil,gui.edges.RIGHT).onDrag:add(gui.drag.scaleParentR) );
		t = gui.draw.sheet( sheets.top:newSheet(50,0,300,20,
				gui.arrange.custom(
						gui.arrange.x.relativePosAndScale,
						gui.arrange.y.fixedPosAndScale))
				.onDrag:add(gui.drag.scaleParentT) );
		l = gui.draw.sheet( sheets.top:newSheet(50,380,300,20,
				gui.arrange.custom(
						gui.arrange.x.relativePosAndScale,
						gui.arrange.y.fixedPosAndScale)
				,gui.edges.BOTTOM,gui.edges.RIGHT)
				.onDrag:add(gui.drag.scaleParentB));

		-- Corners
		tl = gui.draw.sheet( sheets.top:newSheet(0,0,20,20)
				.onDrag:add(gui.drag.scaleParentTL) );
		tr = gui.draw.sheet( sheets.top:newSheet(380,0,20,20,nil,nil,gui.edges.RIGHT)
				.onDrag:add(gui.drag.scaleParentTR) );
		bl = gui.draw.sheet( sheets.top:newSheet(0,380,20,20,nil,gui.edges.BOTTOM,nil)
				.onDrag:add(gui.drag.scaleParentBL) );
		br = gui.draw.sheet( sheets.top:newSheet(380,380,20,20,nil,gui.edges.BOTTOM,gui.edges.RIGHT)
				.onDrag:add(gui.drag.scaleParentBR) );
	};
	sheets.mid = gui.draw.sheet(
			sheets.top:newSheet( 40,40,320,320 ).onDrag:add( gui.drag.moveSheet )
	);
	sheets.midBtn = {
		tl = gui.draw.sheet( sheets.mid:newSheet(0,0,20,20)
				.onDrag:add(gui.drag.scaleParentTL) );
		tr = gui.draw.sheet( sheets.mid:newSheet(300,0,20,20,nil,nil,gui.edges.RIGHT)
				.onDrag:add(gui.drag.scaleParentTR) );
		bl = gui.draw.sheet( sheets.mid:newSheet(0,300,20,20,nil,gui.edges.BOTTOM,nil)
				.onDrag:add(gui.drag.scaleParentBL) );
		br = gui.draw.sheet( sheets.mid:newSheet(300,300,20,20,nil,gui.edges.BOTTOM,gui.edges.RIGHT)
				.onDrag:add(gui.drag.scaleParentBR) );
	};
	sheets.last = gui.draw.sheet(
			sheets.mid:newSheet( 40,40,240,240 ).onDrag:add( gui.drag.moveSheet )
	);
	sheets.lastBtn = {
		tl = gui.draw.sheet( sheets.last:newSheet(0,0,20,20)
				.onDrag:add(gui.drag.scaleParentTL) );
		tr = gui.draw.sheet( sheets.last:newSheet(220,0,20,20,nil,nil,gui.edges.RIGHT)
				.onDrag:add(gui.drag.scaleParentTR) );
		bl = gui.draw.sheet( sheets.last:newSheet(0,220,20,20,nil,gui.edges.BOTTOM,nil)
				.onDrag:add(gui.drag.scaleParentBL) );
		br = gui.draw.sheet( sheets.last:newSheet(220,220,20,20,nil,gui.edges.BOTTOM,gui.edges.RIGHT)
				.onDrag:add(gui.drag.scaleParentBR) );
	};
end;

function test2()
	gui.draw.sheet( desk:newSheet( 190, 0, 20, 600 ) );
	gui.draw.sheet(desk:newSheet( 0, 140, 800, 20 ) );
	gui.draw.sheet( desk:newSheet(380,280,20,20) );
	gui.draw.sheet( desk:newSheet(395,0,10,600) );
	local panel = gui.draw.sheet( desk:newSheet( 0,0,400,300 )
		.onDrag:add(gui.drag.moveSheet) );
	local center = gui.draw.sheet(panel:newSheet(50,50,300,200,gui.arrange.relativePosAndScale));
	local subCenter = gui.draw.sheet( center:newSheet(50,50,200,100,gui.arrange.relativePosAndScale) );
	gui.draw.sheet( center:newSheet(295,195,5,5,nil,gui.edges.BOTTOM, gui.edges.RIGHT) );



	gui.draw.sheet(panel:newSheet(380,280,20,20,nil, gui.edges.BOTTOM, gui.edges.RIGHT)
		.onDrag:add( gui.drag.scaleParentBR ));
	gui.draw.sheet(panel:newSheet(0,0,20,20)
		.onDrag:add( gui.drag.scaleParentTL ));
end;

function load()
	-- Font
	local f = love.graphics.newFont(love.default_font, 14);
	love.graphics.setFont(f);

	gui = require("bdgui.lua");

	desk = gui.draw.desk( gui.newDesk() );

	lastMousePos = {x=0,y=0};

	--test2();
	test1();

end;

function update( elapsed )
	desk:update( elapsed );
	-- Check for mouse movement and eventually call the callback
	if( lastMousePos.x ~= love.mouse.getX()
			or lastMousePos.y ~= love.mouse.getY() ) then

		desk:mousemoved( love.mouse.getX(),love.mouse.getY(),
				lastMousePos.x, lastMousePos.y );
		lastMousePos.x = love.mouse.getX();
		lastMousePos.y = love.mouse.getY();
	end;
end;

function mousepressed( x, y, button )
	desk:mousepressed( x, y, button );
end;

function mousereleased( x, y, button )
	desk:mousereleased( x, y, button );
end;

function keypressed(key)
	if(key == love.key_r) then love.system.restart() end;
end;

function draw(  )
	--local pos = 20;
	desk:draw();
end;