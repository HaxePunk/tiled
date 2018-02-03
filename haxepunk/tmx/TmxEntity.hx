package haxepunk.tmx;

import haxepunk.Entity;
import haxepunk.Graphic;
import haxepunk.assets.AssetLoader;
import haxepunk.graphics.Graphiclist;
import haxepunk.graphics.Image;
import haxepunk.graphics.tile.Tilemap;
import haxepunk.Mask;
import haxepunk.masks.Grid;
import haxepunk.masks.SlopedGrid;
import haxepunk.masks.Masklist;

private abstract Map(TmxMap)
{
	private inline function new(map:TmxMap) this = map;
	@:to public inline function toMap():TmxMap return this;

	@:from public static inline function fromString(s:String)
		return new Map(new TmxMap(Xml.parse(AssetLoader.getText(s))));

	@:from public static inline function fromTmxMap(map:TmxMap)
		return new Map(map);

	@:from public static inline function fromMapData(mapData:MapData)
		return new Map(new TmxMap(mapData));
}

/**
 *  A helper entity that provides helper functions for performing the most common actions with a Tiled Map.
 */
class TmxEntity extends Entity
{
	/**
	 *  The Tiled map of this entity.
	 */
	public var map:TmxMap;
	public var debugObjectMask:Bool;

	/**
	 *  Constructor.
	 *  @param mapData - Any type that can be converted to a TmxMap by the Map abstract.
	 */
	public function new(mapData:Map)
	{
		super();

		map = mapData;
#if debug
		debugObjectMask = true;
#end
	}

	/**
	 *  Creates an Image of an image layer by name on this entity.
	 *  @param name - The name of the image layer to create.
	 */
	public function loadImageLayer(name:String)
	{
		if (!map.imageLayers.exists(name))
		{
#if debug
			trace("Image layer '" + name + "' doesn't exist");
#end
			return;
		}

		addGraphic(new Image(map.imageLayers.get(name)));
	}

	/**
	 *  Creates Tilemaps from with a supplied TileType and list of layer names.
	 *  @param tileset - The tileset to use.
	 *  @param layerNames - The names of the layers to create.
	 *  @param skip - A list of tile gid's to skip.
	 */
	public function loadGraphic(tileset:Graphic.TileType, layerNames:Array<String>, ?skip:Array<Int>)
	{
		var gid:Int, layer:TmxLayer;
		for (name in layerNames)
		{
			if (!map.layers.exists(name))
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
					if (skip == null || !Lambda.has(skip, gid))
					{
						tilemap.setTile(col, row, gid);
					}
				}
			}
			addGraphic(tilemap);
		}
	}

	/**
	 *  Creates a Grid mask from a Tiled layer and sets the type of this entity to typeName.
	 *  @param collideLayer - The layer of the Tiled Map from which to create the Grid.
	 *  @param typeName - The new type of this entity.
	 *  @param skip - A list of tile gid's to skipt.
	 */
	public function loadMask(collideLayer:String = "collide", typeName:String = "solid", ?skip:Array<Int>)
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
				if (skip == null || !Lambda.has(skip, gid))
				{
					grid.setTile(col, row, true);
					tileCoords.push(new TmxVec4(col * map.tileWidth, row * map.tileHeight, map.tileWidth, map.tileHeight));
				}
			}
		}

		this.mask = grid;
		this.type = typeName;
		setHitbox(grid.width, grid.height);
		return tileCoords;
	}
	
// 	public function loadSlopedMask(collideLayer:String = "collide", typeName:String = "solid", skip:Array<Int> = null)
// 	{
// 		if (!map.layers.exists(collideLayer))
// 		{
// #if debug
// 				trace("Layer '" + collideLayer + "' doesn't exist");
// #end
// 			return;
// 		}
		
// 		var gid:Int;
// 		var layer:TmxLayer = map.layers.get(collideLayer);
// 		var grid = new SlopedGrid(map.fullWidth, map.fullHeight, map.tileWidth, map.tileHeight);
// 		var types = Type.getEnumConstructs(TileType);
		
// 		for (row in 0...layer.height)
// 		{
// 			for (col in 0...layer.width)
// 			{
// 				gid = layer.tileGIDs[row][col] - 1;
// 				if (gid < 0) continue;
// 				if (skip == null || Lambda.has(skip, gid) == false)
// 				{
// 					var type = map.getGidProperty(gid + 1, "tileType");
// 					// collideType is null, load as solid tile
// 					if (type == null)
// 						grid.setTile(col, row, Solid);
// 					// load as custom collide type tile
// 					else
// 					{
// 						for(i in 0...types.length)
// 						{
// 							if(type == types[i])
// 							{
// 								grid.setTile(col, row,
// 									Type.createEnum(TileType, type),
// 									Std.parseFloat(map.getGidProperty(gid + 1, "slope")),
// 									Std.parseFloat(map.getGidProperty(gid + 1, "yOffset"))
// 									);
// 								break;
// 							}
// 						}
// 					}
// 				}
// 			}
// 		}
		
// 		this.mask = grid;
// 		this.type = typeName;
// 		setHitbox(grid.width, grid.height);
// 	}

	/*
		debugging shapes of object mask is only availble in -flash
		currently only supports ellipse object (circles only), and rectangle objects
			no polygons yet
	*/

	/**
	 *  Creates a masklist from an object layer.
	 *  
	 *  Currently only supports unrotated circles and hitboxes.
	 *  
	 *  @param collideLayer - The name of the object group/layer.
	 *  @param typeName - The new type of this entity.
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

		var maskArr  = new Array<Mask>();
#if debug
		var debug_graphics_ar = new Array<Graphic>();
#end

		// Loop through objects
		for (object in objectGroup.objects)
		{ // :TmxObject
			maskArr .push(object.shapeMask);
#if debug
			debug_graphics_ar.push(object.debug_graphic);
#end
		}

#if debug
		if (debugObjectMask)
		{
			var debug_graphicList = new Graphiclist(debug_graphics_ar);
			this.addGraphic(debug_graphicList);
		}
#end

		var maskList = new Masklist(maskArr );
		this.mask = maskList;
		this.type = typeName;

	}

}
