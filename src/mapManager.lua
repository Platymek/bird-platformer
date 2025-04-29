
function makeMapManager()
	
	-- ids are used to give names to the maps
	local ids = {}

	-- coordinates in game world
	local coords = {}

	-- coordinates on map editor, using world coordinates as key
	local maps = {}
	
	-- create map manager object and add functions
	local mapManager = {}

	-- id: map id, x,y: where to place the map, 
	-- mapx,mapy: where the map is on the map editor
	mapManager.addMap = function (id, x, y, mapx, mapy)
		
		ids     [#ids + 1]  = id
		coords  [id]        = {x = x, y = y}

		if maps[coords[id].x] == nil then maps[coords[id].x] = {} end
		maps[coords[id].x][coords[id].y] = {x = mapx, y = mapy}
	end

	mapManager.draw = function ()

		for i, id in ipairs(ids) do

			local c = coords[id]
			local cell = { x = c.x * 8 * 16, y = c.y * 8 * 16 }
			local m = maps[c.x][c.y]
			map(m.x * 16, m.y * 16, cell.x, cell.y, 16, 16)
		end
	end

	-- x, y: tile coords (not pixel coords)
	mapManager.hasFlag = function (flag, x, y)
	
		local mc = {x = flr(x/ 16), y = flr(y/ 16)}

		if	 	maps[mc.x] == nil	then return false end
		local 	m = maps[mc.x][mc.y] -- ensure this isn't nil
		if 		m == nil 			then return false end

		return fget(mget(m.x * 16 + x % 16, m.y * 16 + y % 16), flag)
	end
	
	return mapManager
end
