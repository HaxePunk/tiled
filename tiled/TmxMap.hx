package tiled;

import haxe.io.Bytes;
import haxe.xml.Fast;

#if openfl
import openfl.Assets;
#elseif nme
import nme.Assets;
#end

abstract MapData(Fast) to Fast
{
	private inline function new(f:Fast)
		this = f;

	@:from public static inline function fromString(s:String)
		return new MapData(new Fast(Xml.parse(s)));

	@:from public static inline function fromXml(xml:Xml)
		return new MapData(new Fast(xml));

	@:from public static inline function fromByteArray(b:Bytes)
		return new MapData(new Fast(Xml.parse(b.toString())));
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
abstract TmxMapStaggerIndex(String) to String
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
	/** For staggered and hexagonal maps, determines which axis is staggered. */
	public var staggerAxis(default, null):TmxMapStaggerAxis;
	/** For staggered and hexagonal maps, determines whether the "even" or "odd" indexes along the staggered axis are shifted. */
	public var staggerIndex(default, null):TmxMapStaggerIndex;
	/** The background color of the map, optional, may include alpha value in the form #AARRGGBB. */
	public var backgroundColor(default, null):Int;
	/** Stores the next available ID for new objects. This number is stored to prevent reuse of the same ID after objects have been removed. */
	public var nextObjectId(default, null):Int;

	// Map content
	/** The custom properties of the map. */
	public var properties(default, null):Map<String, String>;
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

#if (openfl || nme)
	/** Loads map from asset name. */
	public static function loadFromAsset(name:String):TmxMap
	{
		return new TmxMap(Assets.getText(name));
	}
#end

	public function new(data:MapData)
	{
		properties = new Map<String, String>();
		tilesets = new Array<TmxTileset>();
		layers = new Array<TmxLayer>();
		tileLayers = new Array<TmxTileLayer>();
		objectGroups = new Array<TmxObjectGroup>();
		imageLayers = new Array<TmxImageLayer>();

		var source:Fast = data.node.map;

		// Populate the map informations
		version = source.att.version;
		if (version == null) throw TmxError.MISSING_MAP_VERSION;

		orientation = switch (source.att.orientation) {
			case "orthogonal": ORTHOGONAL;
			case "isometric": ISOMETRIC;
			case "staggered": STAGGERED;
			case "hexagonal": HEXGONAL;
			case null: throw TmxError.MISSING_MAP_ORIENTATION;
			default: throw TmxError.INVALID_MAP_ORIENTATION;
		};

		renderOrder = switch (source.att.renderorder) {
			case "right-down": RIGHT_DOWN;
			case "right-up": RIGHT_UP;
			case "left-down": LEFT_DOWN;
			case "left-up": LEFT_UP;
			case null: throw TmxError.MISSING_MAP_RENDERORDER;
			default: throw TmxError.INVALID_MAP_RENDERORDER;
		};

		width = Std.parseInt(source.att.width);
		if (width == null) throw TmxError.INVALID_MAP_WIDTH;

		height = Std.parseInt(source.att.height);
		if (height == null) throw TmxError.INVALID_MAP_HEIGHT;

		tileWidth = Std.parseInt(source.att.tilewidth);
		if (tileWidth == null) throw TmxError.INVALID_MAP_TILEWIDTH;

		tileHeight = Std.parseInt(source.att.tileheight);
		if (tileHeight == null) throw TmxError.INVALID_MAP_TILEHEIGHT;

		if (orientation == STAGGERED || orientation == HEXAGONAL)
		{
			staggerAxis = switch (source.att.staggeraxis) {
				case "x": X;
				case "y": Y;
				case null: throw TmxError.MISSING_MAP_STAGGERAXIS;
				default: throw TmxError.INVALID_MAP_STAGGERAXIS;
			};

			staggerIndex = switch (source.att.staggerindex) {
				case "even": EVEN;
				case "odd": ODD;
				case null: throw TmxError.MISSING_MAP_STAGGERINDEX;
				default: throw TmxError.INVALID_MAP_STAGGERINDEX;
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
		if (nextObjectId == null) throw TmxError.INVALID_MAP_NEXTOBJECTID;

		// Calculate the entire size
		fullWidth = width * tileWidth;
		fullHeight = height * tileHeight;

		// Load data
		for (node in source.elements)
		{
			switch (node.name)
			{
				case "properties":
					for (property in node.nodes.property)
					{
						properties.set(property.att.name, property.att.value);
					}

				case "tileset":
					tilesets.push(new TmxTileset(node, this));

				case "layer": // Tile layer
					var layer = new TmxTileLayer(node, this);
					layers.push(layer);
					tileLayers.push(layer);

				case "objectgroup":
					var layer = new TmxObjectGroup(node, this);
					layers.push(layer);
					objectGroups.push(layer);

				case "imagelayer":
					var layer = new TmxImageLayer(node, this);
					layers.push(layer);
					imageLayers.push(layer);

				default:
			}
		}
	}
}
