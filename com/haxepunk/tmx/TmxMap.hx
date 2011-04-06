/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;

import haxe.xml.Fast;

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
	public var layers:Hash<TmxLayer>;
	public var tileSets:Hash<TmxTileSet>;
	public var objectGroups:Hash<TmxObjectGroup>;
	
	public function new(data:Dynamic)
	{
		properties = new TmxPropertySet();
		var source:Fast = null;
		var node:Fast = null;
		
		if (Std.is(data, String)) source = new Fast(Xml.parse(data));
		else if (Std.is(data, Xml)) source = new Fast(data);
		else throw "Unknown TMX map format";
		
		layers = new Hash<TmxLayer>();
		tileSets = new Hash<TmxTileSet>();
		objectGroups = new Hash<TmxObjectGroup>();
		
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
			tileSets.set(node.att.name, new TmxTileSet(node, this));
		
		//load layer
		for (node in source.nodes.layer)
			layers.set(node.att.name, new TmxLayer(node, this));
		
		//load object group
		for (node in source.nodes.objectgroup)
			objectGroups.set(node.att.name, new TmxObjectGroup(node, this));
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