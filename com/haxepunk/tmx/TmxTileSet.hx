/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;

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

	@:from public static inline function fromByteArray(ba:ByteArray) {
		var f = new Fast(Xml.parse(ba.toString()));
		return new TileSetData(f.node.tileset);
	}
}

class TmxTileSet
{
	private var _tileProps:Array<TmxPropertySet>;
	private var _image:BitmapData;

	public var firstGID:Int;
	public var name:String;
	public var tileWidth:Int;
	public var tileHeight:Int;
	public var spacing:Int=0;
	public var margin:Int=0;
	public var imageSource:String;

	//available only after image has been assigned:
	public var numTiles:Int;
	public var numRows:Int;
	public var numCols:Int;

	public function new(data:TileSetData)
	{
		var node:Fast, source:Fast;
		numTiles = 0xFFFFFF;
		numRows = numCols = 1;

		source = data;

		firstGID = (source.has.firstgid) ? Std.parseInt(source.att.firstgid) : 1;

		// check for external source
		if (source.has.source)
		{

		}
		else // internal
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
						_tileProps[id].extend(prop);
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
			return _tileProps[gid - firstGID];
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
