package tiled;

import haxe.xml.Fast;
import openfl.Assets;
import openfl.utils.ByteArray;

abstract MapData(Fast)
{
	private inline function new(f:Fast)
		this = f;

	@:to public inline function toMap():Fast
		return this;

	@:from public static inline function fromString(s:String)
		return new MapData(new Fast(Xml.parse(s)));

	@:from public static inline function fromXml(xml:Xml)
		return new MapData(new Fast(xml));

	@:from public static inline function fromByteArray(ba:ByteArray)
		return new MapData(new Fast(Xml.parse(ba.toString())));
}

@:enum
abstract TmxMapOrientation(String) to String
{
	var ORTHOGONAL = "orthogonal";
	var ISOMETRIC = "isometric";
	var STAGGERED = "staggered";
	var HEXGONAL = "hexagonal";
}

@:enum
abstract TmxMapRenderOrder(String) to String
{
	var RIGHT_DOWN = "right-down";
	var RIGHT_UP = "right-up";
	var LEFT_DOWN = "left-down";
	var LEFT_UP = "left-up";
}

@:enum
abstract TmxMapStaggerAxis(String) to String
{
	var X = "x";
	var Y = "y";
	var NONE = "";
}

@:enum
abstract TmxMapStaggerAxis(String) to String
{
	var EVEN = "even";
	var ODD = "odd";
	var NONE = "";
}

class TmxMap
{
	// Map informations
	/** The TMX format version. */
	public var version(default, null):String;
	/** Map orientation */
	public var orientation(default, null):TmxMapOrientation;
	/** The order in which tiles on tile layers are rendered. In all cases, the map is drawn row-by-row, but only supported for orthogonal maps at the moment. */
	public var renderOrder(default, null):TmxMapRenderOrder;
	/** The map width in tiles. */
	public var width(default, null):Int;
	/** The map height in tiles. */
	public var height(default, null):Int;
	/** The width of a tile. */
	public var tileWidth(default, null):Int;
	/** The height of a tile. */
	public var tileHeight(default, null):Int;
	/** For staggered and hexagonal maps, determines which axis ("x" or "y") is staggered. */
	public var staggerAxis(default, null):TmxMapStaggerAxis;
	/** For staggered and hexagonal maps, determines whether the "even" or "odd" indexes along the staggered axis are shifted. */
	public var staggerIndex(default, null):TmxMapStaggerIndex;
	/** The background color of the map, optional, may include alpha value in the form #AARRGGBB. */
	public var backgroundColor(default, null):Int;
	/** Stores the next available ID for new objects. This number is stored to prevent reuse of the same ID after objects have been removed. */
	public var nextObjectId(default, null):Int;

	// Map content
	/** The custom properties of the map. */
	public var properties(default, null):Array<TmxProperty>;
	/** The tilesets of the map. */
	public var tilesets(default, null):Array<TmxTileset>;
	/** The layers can be a combinaison of tile layers, object groups or image layers. */
	public var layers(default, null):Array<TmxLayer>;

	// Custom utility values
	/** The full width of the map in pixels. */
	public var fullWidth(default, null):Int;
	/** The full height of the map in pixels. */
	public var fullHeight(default, null):Int;
	/** Subset of only the tile layers .*/
	public var tileLayers(default, null):Array<TmxTileLayer>;
	/** Subset of only the object groups. */
	public var objectGroups(default, null):Array<TmxObjectGroup>;
	/** Subset of only the image layers. */
	public var imageLayers(default, null):Array<TmxImageLayer>;

	public function new(data:MapData)
	{
		properties = new Array<TmxProperty>();
		tilesets = new Array<TmxTileset>();
		layers = new Array<TmxLayer>();
		tileLayers = new Array<TmxTileLayer>();
		objectGroups = new Array<TmxObjectGroup>();
		imageLayers = new Array<TmxImageLayer>();

		var source:Fast = data.node.map;

		// Populate the map informations
		version = source.att.version;
		if (version == null) throw TmxError.MISSING_VERSION;

		orientation = switch (source.att.orientation) {
			case "orthogonal": ORTHOGONAL;
			case "isometric": ISOMETRIC;
			case "staggered": STAGGERED;
			case "hexagonal": HEXGONAL;
			case null: throw TmxError.MISSING_ORIENTATION;
			default: throw TmxError.INVALID_ORIENTATION;
		};

		renderOrder = switch (source.att.renderorder) {
			case "right-down": RIGHT_DOWN;
			case "right-up": RIGHT_UP;
			case "left-down": LEFT_DOWN;
			case "left-up": LEFT_UP;
			case null: throw TmxError.MISSING_RENDERORDER;
			default: throw TmxError.INVALID_RENDERORDER;
		};

		width = Std.parseInt(source.att.width);
		if (width == null) throw TmxError.INVALID_WIDTH;

		height = Std.parseInt(source.att.height);
		if (height == null) throw TmxError.INVALID_HEIGHT;

		tileWidth = Std.parseInt(source.att.tilewidth);
		if (tileWidth == null) throw TmxError.INVALID_TILEWIDTH;

		tileHeight = Std.parseInt(source.att.tileheight);
		if (tileHeight == null) throw TmxError.INVALID_TILEHEIGHT;

		if (orientation == STAGGERED || orientation == HEXAGONAL)
		{
			staggerAxis = switch (source.att.staggeraxis) {
				case "x": X;
				case "y": Y;
				case null: throw TmxError.MISSING_STAGGERAXIS;
				default: throw TmxError.INVALID_STAGGERAXIS;
			};

			staggerIndex = switch (source.att.staggerindex) {
				case "even": EVEN;
				case "odd": ODD;
				case null: throw TmxError.MISSING_STAGGERINDEX;
				default: throw TmxError.INVALID_STAGGERINDEX;
			};
		}
		else
		{
			staggerAxis = NONE;
			staggerIndex = NONE;
		}

		backgroundColor = Std.parseInt(source.att.tileheight);
		if (backgroundColor == null) backgroundColor = 0; // Optionnal

		nextObjectId = Std.parseInt(source.att.nextobjectid);
		if (nextObjectId == null) throw TmxError.INVALID_NEXTOBJECTID;

		// Calculate the entire size
		fullWidth = width * tileWidth;
		fullHeight = height * tileHeight;

		// Read properties
		for (node in source.nodes.properties)
		{
			properties.push(new TmxProperty(node));
		}

		// Load tilesets
		for (node in source.nodes.tileset)
		{
			tilesets.push(new TmxTileset(node));
		}

		// Load layers
		/*
		for (node in source.nodes.layer)
		{
			layers.set(node.att.name, new TmxLayer(node, this));
		}

		// Load image layer
		for (node in source.nodes.imagelayer)
		{
			for (img in node.nodes.image)
			{
				imageLayers.set(node.att.name, img.att.source.substr(3));
			}
		}

		// Load object group
		for (node in source.nodes.objectgroup)
		{
			objectGroups.set(node.att.name, new TmxObjectGroup(node, this));
		}

		// for (node in source.nodes.imagelayer)
		// 	imageLayers.set(node.att.name, new TmxImageLayer(node));
		*/
	}

	public static function loadFromFile(name:String):TmxMap
	{
		return new TmxMap(Assets.getText(name));
	}

	public function getLayer(name:String):TmxLayer
	{
		return layers.get(name);
	}

	public function getObjectGroup(name:String):TmxObjectGroup
	{
		return objectGroups.get(name);
	}

	// Works only after TmxTileSet has been initialized with an image...
	public function getGidOwner(gid:Int):TmxTileSet
	{
		var last:TmxTileSet = null;
		var set:TmxTileSet;

		for (set in tilesets)
		{
			if (set.hasGid(gid))
			{
				return set;
			}
		}

		return null;
	}

	public function getGidProperty(gid:Int, property:String)
	{
		var last:TmxTileSet = null;
		var set:TmxTileSet;

		for (set in tilesets)
		{
			if (set.hasGid(gid) && set.getPropertiesByGid(gid) != null)
			{
				return set.getPropertiesByGid(gid).resolve(property);
			}
		}

		return null;
	}

	public function getTileMapSpacing(name:String):Int
	{
		var index = -1;
		var i = 0;

		for (key in layers.keys())
		{
			if (key == name)
			{
				index = i;
				break;
			}
		}

		i++;

		if (index == -1)
		{
			return 0;
		}

		return tilesets[index].spacing;
	}
}
