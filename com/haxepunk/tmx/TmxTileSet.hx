/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;

import com.haxepunk.Mask;
import com.haxepunk.masks.Masklist;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import haxe.xml.Fast;
import openfl.Assets;

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
	private var _tileCollisions:Array<Array<TmxCollisionObject>>;
	private var _image:BitmapData;

	public var firstGID:Int;
	public var name:String;
	public var tileWidth:Int;
	public var tileHeight:Int;
	public var spacing:Int=0;
	public var margin:Int=0;
	public var imageSource:String;
	public var offsetX:Int;
	public var offsetY:Int;
	public static var autoLoadImage:Bool = true;

	//available only after image has been assigned:
	public var numTiles:Int;
	public var numRows:Int;
	public var numCols:Int;

	public function new(data:TileSetData)
	{
		var node:Fast, source:Fast;
		numTiles = 0xFFFFFF;
		numRows = numCols = 1;
		offsetX = offsetY = 0;

		source = data;

		firstGID = (source.has.firstgid) ? Std.parseInt(source.att.firstgid) : 1;
		// check for external source
		if (source.has.source)
		{
			source = new Fast(Xml.parse(Assets.getText(TmxMap.patternsPath + source.att.source)));
			source = source.node.tileset;
			//trace(source.node.image);
		}

		node = source.node.image;
		imageSource = node.att.source;

		name = source.att.name;
		if (source.has.tilewidth) tileWidth = Std.parseInt(source.att.tilewidth);
		if (source.has.tileheight) tileHeight = Std.parseInt(source.att.tileheight);
		if (source.has.spacing) spacing = Std.parseInt(source.att.spacing);
		if (source.has.margin) margin = Std.parseInt(source.att.margin);
		if (source.hasNode.tileoffset)
		{
			offsetX = Std.parseInt(source.node.tileoffset.att.x);
			offsetY = Std.parseInt(source.node.tileoffset.att.y);
		}

		//read properties
		_tileProps = new Array<TmxPropertySet>();
		_tileCollisions = new Array<Array<TmxCollisionObject>>();
		for (node in source.nodes.tile)
		{
			if (node.has.id)
			{
				var id:Int = Std.parseInt(node.att.id);
				_tileProps[id] = new TmxPropertySet();
				for (prop in node.nodes.properties)
					_tileProps[id].extend(prop);

				if (node.hasNode.objectgroup)
				{
					var _og:Fast = node.node.objectgroup;
					_tileCollisions[id] = new Array<TmxCollisionObject>();
					for (og in _og.nodes.object)
					{
						var x = Std.parseFloat(og.att.x);
						var y = Std.parseFloat(og.att.y);
						var w = og.has.width ? Std.parseFloat(og.att.width) : tileWidth;
						var h = og.has.height ? Std.parseFloat(og.att.height) : tileHeight;

						if (og.hasNode.polygon)
						{
							var points:Array<String> = og.node.polygon.att.points.split(" ");
							var pArr:Array<Float> = new Array<Float>();
							for (pS in points) {
								pArr.push( x + Std.parseFloat(pS.split(",")[0]));
								pArr.push( y + Std.parseFloat(pS.split(",")[1]));
							}
							_tileCollisions[id].push(new TmxCollisionObject(x, y, w, h, "poly", 0, pArr));
						}
						else if (og.hasNode.ellipse) {
							var radius = Std.int(((w < h)? w : h)/2);
							_tileCollisions[id].push(new TmxCollisionObject(x, y, w, h, "circle", radius));
						}else { // rect
							_tileCollisions[id].push(new TmxCollisionObject(x, y, w, h));
						}
					}
				}
			}
		}

		if (autoLoadImage && imageSource != null && imageSource != "" )
		{
			if (Assets.exists(imageSource, AssetType.IMAGE))
			{
				image = Assets.getBitmapData(imageSource);
			}
			else if (Assets.exists(imageSource.substring(3), AssetType.IMAGE))
			{
				image = Assets.getBitmapData(imageSource.substring(3));
			}
			else
			{
				#if debug
				trace("Cannot load image source", imageSource);
				#end
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
		return new Rectangle( Std.int(id % numCols) * tileWidth , Std.int(id / numCols) * tileHeight, tileWidth, tileHeight);
	}

	public function getCollisionsByGid(gid:Int):Array<TmxCollisionObject>
	{
		if (_tileCollisions != null)
			return _tileCollisions[gid];
		return null;
	}
}
