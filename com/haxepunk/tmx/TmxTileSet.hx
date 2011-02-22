/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;

import flash.display.BitmapData;
import flash.geom.Rectangle;

class TmxTileSet
{
	private var _tileProps:Array<Int>;
	private var _image:BitmapData;
	
	public var firstGID:Int;
	public var map:TmxMap;
	public var name:String;
	public var tileWidth:Int;
	public var tileHeight:Int;
	public var spacing:Int;
	public var margin:Int;
	public var imageSource:String;
	
	//available only after immage has been assigned:
	public var numTiles:Int;
	public var numRows:Int;
	public var numCols:Int;
	
	public function new(source:Xml, parent:TmxMap)
	{
		numTiles = 0xFFFFFF;
		numRows = numCols = 1;
		
		firstGID = source.get("firstgid");

		imageSource = source.image.get("source");
		
		map = parent;
		name = source.get("name");
		tileWidth = source.get("tilewidth");
		tileHeight = source.get("tileheight");
		spacing = source.get("spacing");
		margin = source.get("margin");
			
		//read properties
		var node:Xml;
		for (node in source.tile)
			if(node.properties[0])
				_tileProps[ode.get("id")] = new TmxPropertySet(node.properties[0]);
	}
	
	public var image(getImage, setImage):BitmapData;
	private function getImage():BitmapData
	{
		return _image;
	}
	public function setImage(v:BitmapData):BitmapData
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
		return _tileProps[gid - firstGID];	
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