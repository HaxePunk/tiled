package com.haxepunk.tmx;

import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.masks.Grid;

class TmxEntity extends Entity
{

	public var map:TmxMap;

	public function new(mapData:Dynamic)
	{
		super();

		if (Std.is(mapData, String))
		{
			map = new TmxMap(nme.Assets.getBytes(mapData));
		}
		else if (Std.is(mapData, TmxMap))
		{
			map = mapData;
		}
		else
		{
			map = new TmxMap(mapData);
		}
	}

	public function loadGraphic(tileset:Dynamic, layerNames:Array<String>, skip:Array<Int> = null)
	{
		var gid:Int, layer:TmxLayer;
		for (name in layerNames)
		{
			if (map.layers.exists(name) == false)
			{
#if debug
				trace("Layer '" + name + "' doesn't exist");
#end
				continue;
			}
			layer = map.layers.get(name);

			var tilemap = new Tilemap(tileset, map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight);
			// Loop through tile layer ids
			for (row in 0...layer.height)
			{
				for (col in 0...layer.width)
				{
					gid = layer.tileGIDs[row][col] - 1;
					if (gid < 0) continue;
					if (skip == null || Lambda.has(skip, gid) == false)
					{
						tilemap.setTile(col, row, gid);
					}
				}
			}
			addGraphic(tilemap);
		}
	}

	public function loadMask(collideLayer:String = "collide", typeName:String = "solid", skip:Array<Int> = null)
	{
		if (!map.layers.exists(collideLayer))
		{
#if debug
				trace("Layer '" + collideLayer + "' doesn't exist");
#end
			return;
		}

		var gid:Int;
		var layer:TmxLayer = map.layers.get(collideLayer);
		var grid = new Grid(map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight);

		// Loop through tile layer ids
		for (row in 0...layer.height)
		{
			for (col in 0...layer.width)
			{
				gid = layer.tileGIDs[row][col] - 1;
				if (gid < 0) continue;
				if (skip == null || Lambda.has(skip, gid) == false)
				{
					grid.setTile(col, row, true);
				}
			}
		}

		this.mask = grid;
		this.type = typeName;
		setHitbox(grid.width, grid.height);
	}

}
