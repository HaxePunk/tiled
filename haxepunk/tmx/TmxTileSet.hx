/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package haxepunk.tmx;

import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import haxe.xml.Fast;

abstract TileSetData(Fast)
{
	private inline function new(f:Fast) this = f;
	@:to public inline function toMap():Fast return this;

	@:from public static inline function fromFast(f:Fast)
		return new TileSetData(f);

	@:from public static inline function fromByteArray(ba:ByteArray)
	{
		var f = new Fast(Xml.parse(ba.toString()));
		return new TileSetData(f.node.tileset);
	}
}

/**
 *  A Tiled TileSet.
 */
class TmxTileSet
{
	private var _tileProps:Array<TmxPropertySet>;
	private var _image:BitmapData;

	/**
	 *  The first global tile ID of this tileset (this global ID maps to the first tile in this tileset).
	 */
	public var firstGID:Int;

	/**
	 *  The name of this tileset.
	 */
	public var name:String;

	/**
	 *  The (maximum) width of the tiles in this tileset.
	 */
	public var tileWidth:Int;

	/**
	 *  The (maximum) height of the tiles in this tileset.
	 */
	public var tileHeight:Int;

	/**
	 *  The spacing in pixels between the tiles in this tileset (applies to the tileset image).
	 */
	public var spacing:Int=0;

	/**
	 *  The margin around the tiles in this tileset (applies to the tileset image).
	 */
	public var margin:Int=0;

	/**
	 *  The source image of this tileset.
	 */
	public var imageSource:String;

	/**
	 *  The width of the source image.
	 */
	public var imageWidth:Int;

	/**
	 *  The height of the source image.
	 */
	public var imageHeight:Int;

	/**
	 *  Number of tiles in this tileset.
	 *  
	 *  Only available after image has been assigned.
	 */
	public var numTiles:Int;

	/**
	 *  Number of rows in this tileset.
	 *  
	 *  Only available after image has been assigned.
	 */
	public var numRows:Int;

	/**
	 *  Number of columns in this tileset.
	 *  
	 *  Only available after image has been assigned.
	 */
	public var numCols:Int;

	/**
	 *  Constructor.
	 *  @param data - 
	 */
	public function new(data:TileSetData)
	{
		var node:Fast, source:Fast;
		numTiles = 0xFFFFFF;
		numRows = numCols = 1;

		source = data;

		firstGID = (source.has.firstgid) ? Std.parseInt(source.att.firstgid) : 1;

		// check for external source
		if (source.has.source) {}
		else // internal
		{
			var node:Fast = source.node.image;
			imageSource = node.att.source;
			if (node.has.width) imageWidth = Std.parseInt(node.att.width);
			if (node.has.height) imageHeight = Std.parseInt(node.att.height);
			
			name = source.att.name;
			if (source.has.tilewidth) tileWidth = Std.parseInt(source.att.tilewidth);
			if (source.has.tileheight) tileHeight = Std.parseInt(source.att.tileheight);
			if (source.has.spacing) spacing = Std.parseInt(source.att.spacing);
			if (source.has.margin) margin = Std.parseInt(source.att.margin);

			//read properties
			_tileProps = new Array<TmxPropertySet>();
			for (node in source.nodes.tile)
			{
				if (node.has.id)
				{
					var id:Int = Std.parseInt(node.att.id);
					_tileProps[id] = new TmxPropertySet();
					for (prop in node.nodes.properties)
						_tileProps[id].extend(prop);
				}
			}
		}
	}

	/**
	 *  The image of this tileset from which tiles are indexed.
	 */
	public var image(get_image, set_image):BitmapData;
	private function get_image():BitmapData
	{
		return _image;
	}
	public function set_image(v:BitmapData):BitmapData
	{
		_image = v;
		//TODO: consider spacing & margin
		numCols = Math.floor(v.width / tileWidth);
		numRows = Math.floor(v.height / tileHeight);
		numTiles = numRows * numCols;
		return _image;
	}

	/**
	 *  Checks if a gid exists in this tileset.
	 *  @param gid - The gid to look for.
	 *  @return Bool True if exists.
	 */
	public function hasGid(gid:Int):Bool
	{
		return (gid >= firstGID) && (gid < firstGID + numTiles);
	}

	/**
	 *  Gets the index of a tile from it's gid.
	 *  @param gid - The gid of the tile.
	 *  @return Int
	 */
	public function fromGid(gid:Int):Int
	{
		return gid - firstGID;
	}

	/**
	 *  Gets the gid of a tile from it's index.
	 *  @param id - The index of the tile.
	 *  @return Int
	 */
	public function toGid(id:Int):Int
	{
		return firstGID + id;
	}

	/**
	 *  Gets the custom properties of a tile by its gid.
	 *  @param gid - The gid of the tile.
	 *  @return TmxPropertySet
	 */
	public function getPropertiesByGid(gid:Int):TmxPropertySet
	{
		if (_tileProps != null)
			return _tileProps[gid - firstGID];
		return null;
	}

	/**
	 *  Gets the custom properties of a tile by its index.
	 *  @param id - The index of the tile.
	 *  @return TmxPropertySet
	 */
	public function getProperties(id:Int):TmxPropertySet
	{
		return _tileProps[id];
	}

	/**
	 *  Gets a rectangle outlining the tile found at the supplied index.
	 *  @param id - The index of the tile.
	 *  @return Rectangle
	 */
	public function getRect(id:Int):Rectangle
	{
		//TODO: consider spacing & margin
		return new Rectangle((id % numCols) * tileWidth, (id / numCols) * tileHeight);
	}
}
