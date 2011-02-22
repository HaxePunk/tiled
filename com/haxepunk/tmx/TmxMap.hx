/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;

class TmxMap
{
	public var version:String; 
	public var orientation:String;
	public var width:UInt;
	public var height:UInt; 
	public var tileWidth:UInt; 
	public var tileHeight:UInt;
	
	public var properties:TmxPropertySet;
	public var layers:Hash<TmxLayer>;
	public var tileSets:Hash<TmxTileSet>;
	public var objectGroups:Hash<TmxObjectGroup>;
	
	public function new(data:Dynamic)
	{
		properties = null;
		var source:Xml = null;
		
		if (Std.is(data, String)) source = Xml.parse(data);
		else if (Std.is(data, Xml)) source = data;
		
		layers = new Hash<TmxLayer>();
		tileSets = new Hash<TmxTileSet>();
		objectGroups = new Hash<TmxObjectGroup>();
		
		source = source.firstElement(); // <map>
		
		//map header
		version = (source.get("version") != null) ? source.get("version") : "unknown"; 
		orientation = (source.get("orientation") != null) ? source.get("orientation") : "orthogonal";
		width = Std.parseInt(source.get("width"));
		height = Std.parseInt(source.get("height"));
		tileWidth = Std.parseInt(source.get("tilewidth"));
		tileHeight= Std.parseInt(source.get("tileheight"));
		
		//read properties
		for (node in source.elementsNamed("properties"))
			properties = (properties != null) ? properties.extend(node) : new TmxPropertySet(node);
		
		//load tilesets
		var node:Xml = null;
		for (node in source.elementsNamed("tileset"))
			tileSets.set(node.get("name"), new TmxTileSet(node, this));
		
		//load layer
		for (node in source.elementsNamed("layer"))
			layers.set(node.get("name"), new TmxLayer(node, this));
		
		//load object group
		for (node in source.elementsNamed("objectgroup"))
			objectGroups.set(node.get("name"), new TmxObjectGroup(node, this));
	}
	
	public function getTileSet(name:String):TmxTileSet
	{
		return tileSets.get(name);
	}
	
	public function getLayer(name:String):TmxLayer
	{
		return layers.get(name);
	}
	
	public function getObjectGroup(name:String):TmxObjectGroup
	{
		return objectGroups.get(name);
	}
	
	public function setProperty(name:String, value:String)
	{
		if (properties == null) return;
		Reflect.setField(properties, name, value);
	}
	
	public function checkProperty(name:String):String
	{
		if (properties == null) return null;
		
		return Reflect.field(properties, name);
	}
	
	//works only after TmxTileSet has been initialized with an image...
	public function getGidOwner(gid:Int):TmxTileSet
	{
		var last:TmxTileSet = null;
		var tileSet:TmxTileSet;
		for (tileSet in tileSets)
		{
			if(tileSet.hasGid(gid))
				return tileSet;
		}
		return null;
	}
}