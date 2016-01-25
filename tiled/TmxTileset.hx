package tiled;

import haxe.xml.Fast;

class TmxTileset
{
	// Tileset informations
	/** The first global tile ID of this tileset (this global ID maps to the first tile in this tileset). */
	public var firstGID(default, null):Int;
	/** f this tileset is stored in an external TSX (Tile Set XML) file, this attribute refers to that file. */
	public var source(default, null):String;
	/** The name of this tileset. */
	public var name(default, null):String;
	/** The (maximum) width of the tiles in this tileset. */
	public var tileWidth(default, null):Int;
	/** The (maximum) height of the tiles in this tileset. */
	public var tileHeight(default, null):Int;
	/** The spacing in pixels between the tiles in this tileset (applies to the tileset image). */
	public var spacing(default, null):Int;
	/** The margin around the tiles in this tileset (applies to the tileset image). */
	public var margin(default, null):Int;
	/** The number of tiles in this tileset. */
	public var tileCount(default, null):Int;
	/** The number of tile columns in the tileset. */
	public var columns(default, null):Int;

	// Tileset content
	/** The properties of the tileset. */
	public var properties(default, null):Map<String, String>;
	/** Horizontal rendering offset for the tiles from this tileset in pixels. */
	public var offsetX(default, null):Int;
	/** Vertical rendering offset for the tiles from this tileset in pixels. */
	public var offsetY(default, null):Int;
	/** The images of this tileset. */
	public var images(default, null):Array<TmxImage>;
	/** The terrain types of this tileset. */
	public var terrainTypes(default, null):Array<TmxTerrain>;
	/** The tiles of this tileset. */
	public var tiles(default, null):Array<TmxTile>;

	// Custom utility values
	/** The number of tile rows in the tileset. */
	public var rows(default, null):Int;

	public function new(source:Fast, map:TmxMap)
	{
		var node:Fast, source:Fast;
		numTiles = 0xFFFFFF;
		numRows = numCols = 1;

		source = data;

		firstGID = (source.has.firstgid) ? Std.parseInt(source.att.firstgid) : 1;

		// Check for external source
		if (source.has.source)
		{
			//TODO
		}
		else // Internal
		{
			var node:Fast = source.node.image;
			imageSource = node.att.source;

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
					{
						_tileProps[id].extend(prop);
					}
				}
			}
		}
	}

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

	public function hasGid(gid:Int):Bool
	{
		return (gid >= firstGID) && (gid < firstGID + numTiles);
	}

	public function fromGid(gid:Int):Int
	{
		return gid - firstGID;
	}

	public function toGid(id:Int):Int
	{
		return firstGID + id;
	}

	public function getPropertiesByGid(gid:Int):TmxPropertySet
	{
		if (_tileProps != null)
		{
			return _tileProps[gid - firstGID];
		}

		return null;
	}

	public function getProperties(id:Int):TmxPropertySet
	{
		return _tileProps[id];
	}

	public function getRect(id:Int):Rectangle
	{
		//TODO: consider spacing & margin
		return new Rectangle((id % numCols) * tileWidth, (id / numCols) * tileHeight);
	}
}
