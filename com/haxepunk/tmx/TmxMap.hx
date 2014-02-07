/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;

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

class TmxMap
{
	public var version:String;
	public var orientation:String;

	public var width:Int;
	public var height:Int;
	public var tileWidth:Int;
	public var tileHeight:Int;
	public var fullWidth:Int;
	public var fullHeight:Int;

	public var properties(default, null):TmxPropertySet;
	public var tilesets:Array<TmxTileSet>;
	public var layers:TmxOrderedHash<TmxLayer>;
	public var imageLayers:Map<String, String>;
	public var objectGroups:TmxOrderedHash<TmxObjectGroup>;

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

	//works only after TmxTileSet has been initialized with an image...
	public function getGidOwner(gid:Int):TmxTileSet
	{
		var last:TmxTileSet = null;
		var set:TmxTileSet;
		for (set in tilesets)
		{
			if(set.hasGid(gid))
				return set;
		}
		return null;
	}
	
	public function getGidProperty(gid:Int, property:String)
	{
		var last:TmxTileSet = null;
		var set:TmxTileSet;
		for (set in tilesets)
		{
			if(set.hasGid(gid) && set.getPropertiesByGid(gid) != null)
				return set.getPropertiesByGid(gid).resolve(property);
		}
		return null;
	}

	public function getTileMapSpacing(name:String):Int
	{
		var index = -1;
		var i = 0;
		for (key in layers.keys())
			if (key == name)
			{
				index = i;
				break;
			}
			i++;

		if (index == -1)
			return 0;
		return tilesets[index].spacing;
	}
}
