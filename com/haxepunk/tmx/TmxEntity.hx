package com.haxepunk.tmx;

import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.masks.Grid;
import flash.display.BitmapData;

class TmxEntity extends Entity
{
	
	public var tilemaps:Array<Graphic>;

	public function new(map:TmxMap, bd:BitmapData, collideLayer:String = "collide", collideIndex:Int = 0) 
	{
		super();
		var tilemap:Tilemap;
		var layer:TmxLayer;
		
		tilemaps = new Array<Graphic>();
		_grid = new Grid(map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight);
		
		for (layer in map.layers)
		{
			tilemap = new Tilemap(bd, map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight);
			// Loop through tile layer ids
			for (row in 0...layer.tileGIDs.length)
			{
				for (col in 0...layer.tileGIDs[row].length)
				{
					// if the tile is not null, set it
					if (layer.tileGIDs[row][col] != 0)
					{
						tilemap.setTile(col, row, layer.tileGIDs[row][col] - 1);
						// if this is the collision layer, mark the tile as collidable
						if (layer.name == collideLayer && layer.tileGIDs[row][col] > collideIndex)
						{
							_grid.setTile(col, row, true);
						}
					}
				}
			}
			tilemaps.push(tilemap);
		}
		
		graphic = new Graphiclist(tilemaps);
		mask = _grid;
		type = "solid";
		setHitbox(_grid.width, _grid.height);
	}
	
	private var _grid:Grid;
	
}