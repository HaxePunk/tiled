package com.haxepunk.tmx;

import com.haxepunk.Entity;
import com.haxepunk.Graphic;
import com.haxepunk.graphics.Graphiclist;
import com.haxepunk.graphics.Image;
import com.haxepunk.graphics.Tilemap;
import com.haxepunk.masks.Grid;
import com.haxepunk.masks.SlopedGrid;
import com.haxepunk.masks.Masklist;
import com.haxepunk.tmx.TmxMap;
import com.haxepunk.tmx.TmxTileSet;
import com.haxepunk.tmx.TmxCollisionObject;
import com.haxepunk.masks.Circle;
import com.haxepunk.masks.Hitbox;
import com.haxepunk.masks.Polygon;
import flash.geom.Rectangle;
import com.haxepunk.graphics.atlas.TileAtlas;


private abstract TmxMapData(TmxMap)
{
	private inline function new(map:TmxMap) this = map;
	@:to public inline function toMap():TmxMap return this;

	@:from public static inline function fromString(s:String)
		return new TmxMapData(new TmxMap(Xml.parse(openfl.Assets.getText(s))));

	@:from public static inline function fromTmxMap(map:TmxMap)
		return new TmxMapData(map);

	@:from public static inline function fromMapData(mapData:MapData)
		return new TmxMapData(new TmxMap(mapData));
}

class TmxEntity extends Entity
{

	public var map:TmxMap;
	public var debugObjectMask:Bool;

	public function new(mapData:TmxMapData)
	{
		super();

		map = mapData;
#if debug
		debugObjectMask = true;
#end
	}

	public function loadImageLayer(name:String)
	{
		if (map.imageLayers.exists(name) == false)
		{
#if debug
			trace("Image layer '" + name + "' doesn't exist");
#end
			return;
		}

		addGraphic(new Image(map.imageLayers.get(name)));
	}

	public function loadGraphic(tileset:String, layerNames:Array<String>, skip:Array<Int> = null)
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
			var spacing = map.getTileMapSpacing(name);

			var tilemap = new Tilemap(tileset, map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight, spacing, spacing);

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

	/**
	 * Loads all graphics for the layers in layerNames and, optionally, loads collision information from tiles and sets masks with that
	 * @param	layerNames 		layers you want to show
	 * @param	skip 			gid of tiles that should be skipped.
	 * @param	collideLayer 	the name of the layer to collide with. (ignored if addTileMask = false)
	 * @param	addTileMask 	if we should process tile collision information and generate a mask.
	 * @param	typeName		the type to set for masks.
	 */
	public function loadGraphics(layerNames:Array<String>, skip:Array<Int> = null, collideLayer:String = "collide", addTileMask:Bool = false, typeName:String = "solid"):Void
	{
		var gid:Int;
		var layer:TmxLayer;
		var ml:Masklist = null;
		var tilesCollisions:Array<TmxCollisionObject> = new Array<TmxCollisionObject>();
		var tileMaps:TmxOrderedHash<TmxTilemap> = new TmxOrderedHash<TmxTilemap>();

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
			if (!layer.visible)
			{
#if debug
				trace("Layer '" + name + "' is not visible.");
#end
				continue;
			}
			for (row in 0...layer.height)
			{
				for (col in 0...layer.width)
				{
					gid = layer.tileGIDs[row][col];
					if (gid < 0) continue;
					var set = map.getGidOwner(gid);
					if (set == null)
						continue;
					gid -= set.firstGID;

					if (gid < 0) continue;

					if (!tileMaps.exists( name + "_" + set.name))
					{
						#if flash
						var _tileset = set.image;
						#else
						var _tileset = new TileAtlas(set.image);
						#end
						var tm:TmxTilemap = new TmxTilemap(_tileset, map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight, set.spacing, set.spacing, set.offsetX, set.offsetY);
						tileMaps.set(name + "_" + set.name, tm);
					}

					if (skip == null || Lambda.has(skip, gid) == false)
					{
						if (addTileMask && name == collideLayer)
						{
							var tileMask:Array<TmxCollisionObject> = set.getCollisionsByGid(gid);
							if (tileMask != null && tileMask.length > 0)
							{
								var rect:Rectangle = new Rectangle(x + (col * set.tileWidth), y + (row * set.tileHeight), set.tileWidth, set.tileHeight);
								for (colObj in tileMask)
								{
									var _colObj:TmxCollisionObject = new TmxCollisionObject(colObj.x + rect.x, colObj.y + rect.y, colObj.width, colObj.height, colObj.type, colObj.radius, colObj.polyPoints);
									if (_colObj.type == "poly")
									{
										var pArr:Array<Float> = new Array<Float>();
										var even:Bool = true;
										for (p in _colObj.polyPoints)
										{
											pArr.push(p + (even ? rect.x : rect.y));
											even = !even;
										}
										_colObj.polyPoints = pArr;
									}
									tilesCollisions.push(_colObj);
								}
							}
							else
							{
								#if debug
								trace("You have a tile in layer " + name + " with id: " + gid + " that has no collision setup");
								#end
							}
						}
						tileMaps.get(name + "_" + set.name).setTile(col, row, gid);
					}
				}
			}
			for (tm in tileMaps)
			{
				addGraphic(tm);
			}
		}
		if (addTileMask && tilesCollisions.length > 0)
		{
			var co:TmxCollisionObject;
			var masks:Array<Mask> = new Array<Mask>();
			for (co in tilesCollisions)
			{
				switch (co.type)
				{
					case "circle":
						masks.push(new Circle(co.radius, Std.int(co.x), Std.int(co.y)));
						#if debug
						trace("Adding circle mask");
						if (debugObjectMask)
						{
							var c = Image.createCircle(co.radius, 0xFF0000, 0.5);
							c.x = Std.int(co.x);
							c.y = Std.int(co.y);
							addGraphic(c);
						}
						#end
					case "poly":
						var p:Polygon = Polygon.createFromArray(co.polyPoints);
						p.x = 0;
						p.y = 0;
						masks.push(p);
						#if debug
						trace("Adding poly mask");
						if (debugObjectMask)
						{
							var i:Image = Image.createPolygon(p, 0xFF0000, 0.5);
							addGraphic(i);
						}
						#end
					case "box":
						masks.push( new Hitbox(Std.int(co.width), Std.int(co.height), Std.int(co.x), Std.int(co.y)));
						#if debug
						trace("Adding box mask");
						if (debugObjectMask)
						{
							var i:Image = Image.createRect(Std.int(co.width), Std.int(co.height), 0xFF0000, 0.5);
							i.x = Std.int(co.x);
							i.y = Std.int(co.y);
							addGraphic(i);
						}
						#end
				}
			}
			ml = new Masklist(masks);
			mask = ml;
			this.type = typeName;
			setHitbox(map.fullWidth, map.fullHeight);
		}
	}

	public function loadMask(collideLayer:String = "collide", typeName:String = "solid", skip:Array<Int> = null)
	{
		var tileCoords:Array<TmxVec4> = new Array<TmxVec4>();
		if (!map.layers.exists(collideLayer))
		{
#if debug
				trace("Layer '" + collideLayer + "' doesn't exist");
#end
			return tileCoords;
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
					tileCoords.push(new TmxVec4(col*map.tileWidth, row*map.tileHeight, map.tileWidth, map.tileHeight));
				}
			}
		}

		this.mask = grid;
		this.type = typeName;
		setHitbox(grid.width, grid.height);
		return tileCoords;
	}

	public function loadSlopedMask(collideLayer:String = "collide", typeName:String = "solid", skip:Array<Int> = null)
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
		var grid = new SlopedGrid(map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight);
		var types = Type.getEnumConstructs(TileType);

		for (row in 0...layer.height)
		{
			for (col in 0...layer.width)
			{
				gid = layer.tileGIDs[row][col] - 1;
				if (gid < 0) continue;
				if (skip == null || Lambda.has(skip, gid) == false)
				{
					var type = map.getGidProperty(gid + 1, "tileType");
					// collideType is null, load as solid tile
					if (type == null)
						grid.setTile(col, row, Solid);
					// load as custom collide type tile
					else
					{
						for(i in 0...types.length)
						{
							if(type == types[i])
							{
								grid.setTile(col, row,
									Type.createEnum(TileType, type),
									Std.parseFloat(map.getGidProperty(gid + 1, "slope")),
									Std.parseFloat(map.getGidProperty(gid + 1, "yOffset"))
									);
								break;
							}
						}
					}
				}
			}
		}

		this.mask = grid;
		this.type = typeName;
		setHitbox(grid.width, grid.height);
	}

	/*
		debugging shapes of object mask is only availble in -flash
		currently only supports ellipse object (circles only), and rectangle objects
			no polygons yet
	*/
	public function loadObjectMask(collideLayer:String = "objects", typeName:String = "solidObject")
	{
		if (map.getObjectGroup(collideLayer) == null)
		{
#if debug
				trace("ObjectGroup '" + collideLayer + "' doesn't exist");
#end
			return;
		}

		var objectGroup:TmxObjectGroup = map.getObjectGroup(collideLayer);

		var masks_ar = new Array<Dynamic>();
#if debug
		var debug_graphics_ar = new Array<Graphic>();
#end

		// Loop through objects
		for(object in objectGroup.objects){ // :TmxObject
			masks_ar.push(object.shapeMask);
#if debug
			debug_graphics_ar.push(object.debug_graphic);
#end
		}

#if debug
		if(debugObjectMask){
			var debug_graphicList = new Graphiclist(debug_graphics_ar);
			this.addGraphic(debug_graphicList);
		}
#end

		var maskList = new Masklist(masks_ar);
		this.mask = maskList;
		this.type = typeName;

	}

}
