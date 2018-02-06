/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package haxepunk.tmx;

import haxe.xml.Fast;
import flash.utils.ByteArray;

#if nme
import nme.Assets;
#else
import openfl.Assets;
#end

abstract MapData(Fast)
{
	private inline function new(f:Fast) this = f;
	@:to public inline function toMap():Fast return this;

	@:from public static inline function fromString(s:String)
		return new MapData(new Fast(Xml.parse(s)));

	@:from public static inline function fromXml(xml:Xml)
		return new MapData(new Fast(xml));

	@:from public static inline function fromByteArray(ba:ByteArray)
		return new MapData(new Fast(Xml.parse(ba.toString())));
}

/**
 *  The top level class that represents a Tiled Map in code.
 */
class TmxMap
{
	/**
	 *  Version of the TMX format used.
	 */
	public var version:String;

	/**
	 *  Map orientation. Tiled supports “orthogonal”, “isometric”, “staggered” and “hexagonal” (since 0.11).
	 */
	public var orientation:String;

	/**
	 *  The map width in tiles.
	 */
	public var width:Int;

	/**
	 *  The map height in tiles.
	 */
	public var height:Int;

	/**
	 *  The width of a tile.
	 */
	public var tileWidth:Int;

	/**
	 *  The height of a tile.
	 */
	public var tileHeight:Int;

	/**
	 *  The full width of the map in pixels.
	 */
	public var fullWidth:Int;

	/**
	 *  The full height of the map in pixels.
	 */
	public var fullHeight:Int;

	/**
	 *  The custom properties of this map.
	 */
	public var properties(default, null):TmxPropertySet;

	/**
	 *  The tilesets of this map.
	 */
	public var tilesets:Array<TmxTileSet>;

	/**
	 *  The tile layers in this map.
	 */
	public var layers:TmxOrderedHash<TmxLayer>;

	/**
	 *  The image layers in this map.
	 */
	public var imageLayers:Map<String, String>;

	/**
	 *  The object groups/layers in this map.
	 */
	public var objectGroups:TmxOrderedHash<TmxObjectGroup>;

	/**
	 *  Constructor.
	 *  @param data - Data to load that defins this TmxMap.
	 */
	public function new(data:MapData)
	{
		properties = new TmxPropertySet();
		var source:Fast = null;
		var node:Fast = null;

		source = data;

		tilesets = new Array<TmxTileSet>();
		layers = new TmxOrderedHash<TmxLayer>();
		imageLayers = new Map<String, String>();
		objectGroups = new TmxOrderedHash<TmxObjectGroup>();

		source = source.node.map;

		//map header
		version = source.att.version;
		if (version == null) version = "unknown";

		orientation = source.att.orientation;
		if (orientation == null) orientation = "orthogonal";

		width = Std.parseInt(source.att.width);
		height = Std.parseInt(source.att.height);
		tileWidth = Std.parseInt(source.att.tilewidth);
		tileHeight = Std.parseInt(source.att.tileheight);
		// Calculate the entire size
		fullWidth = width * tileWidth;
		fullHeight = height * tileHeight;

		//read properties
		for (node in source.nodes.properties)
			properties.extend(node);

		//load tilesets
		for (node in source.nodes.tileset)
			tilesets.push(new TmxTileSet(node));

		//load layer
		for (node in source.nodes.layer)
			layers.set(node.att.name, new TmxLayer(node, this));

		//load image layer
		for (node in source.nodes.imagelayer)
		{
			for (img in node.nodes.image)
			{
				imageLayers.set(node.att.name, img.att.source.substr(3));
			}
		}

		//load object group
		for (node in source.nodes.objectgroup)
			objectGroups.set(node.att.name, new TmxObjectGroup(node, this));

		// for (node in source.nodes.imagelayer)
		// 	imageLayers.set(node.att.name, new TmxImageLayer(node));
	}

	/**
	 *  Loads a TmxMap from a specified file in the assets.
	 *  @param name - The file to load.
	 *  @return TmxMap
	 */
	public static function loadFromFile(name:String):TmxMap
	{
		return new TmxMap(Assets.getText(name));
	}

	/**
	 *  Gets a tile layer from this map by name.
	 *  @param name - The name of the tile layer.
	 *  @return TmxLayer
	 */
	public function getLayer(name:String):TmxLayer
	{
		return layers.get(name);
	}

	/**
	 *  Gets an object group from this map by name.
	 *  @param name - The name of the object group.
	 *  @return TmxObjectGroup
	 */
	public function getObjectGroup(name:String):TmxObjectGroup
	{
		return objectGroups.get(name);
	}

	/**
	 *  Gets the tileset which owns a specific tile gid.
	 *  
	 *  Only works after a TmxTileSet has been initialized with an image.
	 *  
	 *  @param gid - The gid to use for the search.
	 *  @return TmxTileSet
	 */
	public function getGidOwner(gid:Int):TmxTileSet
	{
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
	
	/**
	 *  Gets a named property for a specific tile gid.
	 *  
	 *  Only works after a TmxtileSet has been initialized with an image.
	 *  
	 *  @param gid - The gid of the tile.
	 *  @param property - The named property of the tile to retrieve.
	 *  @return String
	 */
	public function getGidProperty(gid:Int, property:String):String
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

	/**
	 *  Gets the spacing for the tileset used in a layer.
	 *  @param name - Name of the layer.
	 *  @return Int
	 */
	public function getTileMapSpacing(name:String):Int
	{
		var layer = layers.get(name);
		for (tileset in tilesets)
		{
			if(tileset.hasGid(layer.firstGID))
			{
				return tileset.spacing;
			}
		}

		return 0;
	}
}
