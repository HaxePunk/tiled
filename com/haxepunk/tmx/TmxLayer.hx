/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package com.haxepunk.tmx;

import flash.utils.ByteArray;
import flash.utils.Endian;
import flash.Lib;

class TmxLayer
{
	public var map:TmxMap;
	public var name:String;
	public var x:Int;
	public var y:Int;
	public var width:Int;
	public var height:Int;
	public var opacity:Float;
	public var visible:Bool;
	public var tileGIDs:Array<Array<Int>>;
	public var properties:TmxPropertySet;
	
	public function new(source:Xml, parent:TmxMap)
	{
		var node:Xml;
		properties = null;
		map = parent;
		
		name = source.get("name");
		x = Std.parseInt(source.get("x"));
		y = Std.parseInt(source.get("y")); 
		width = Std.parseInt(source.get("width")); 
		height = Std.parseInt(source.get("height")); 
		visible = (source.get("visible") == "1") ? true : false;
		opacity = Std.parseFloat(source.get("opacity"));
		
		//load properties
		for (node in source.elementsNamed("properties"))
			properties = (properties != null) ? properties.extend(node) : new TmxPropertySet(node);
		
		//load tile GIDs
		tileGIDs = new Array<Array<Int>>();
		for (node in source.elementsNamed("data"))
		{
			var chunk:String = node.toString();
			switch(node.get("encoding"))
			{
				case "csv":
					tileGIDs = csvToArray(chunk, width);
				case "base64":
					var compressed:Bool = false;
					var time:Float = Lib.getTimer();
					switch(node.get("compression"))
					{
						case "zlib":
							compressed = true;
						default:
							throw "TmxLayer - data compression type not supported!";
					}
					var i:Int;
					for (i in 0...100)
						tileGIDs = base64ToArray(chunk, width, compressed);	
				default:
					//create a 2dimensional array
					var lineWidth:Int = width;
					var rowIdx:Int = -1;
					for (node in node.elementsNamed("tile"))
					{
						//new line?
						if(++lineWidth >= width)
						{
							tileGIDs[++rowIdx] = [];
							lineWidth = 0;
						}
						var gid:Int = Std.parseInt(node.get("gid"));
						tileGIDs[rowIdx].push(gid);
					}
			}
		}
	}
	
	public function toCsv(tileSet:TmxTileSet = null):String
	{
		var max:Int = 0xFFFFFF;
		var offset:Int = 0;
		if(tileSet != null)
		{
			offset = tileSet.firstGID;
			max = tileSet.numTiles - 1;
		}
		var result:String = "";
		var row:Array<Int>;
		for (row in tileGIDs)
		{
			var chunk:String = "";
			var id:Int = 0;
			for (id in row)
			{
				id -= offset;
				if(id < 0 || id > max)
					id = 0;
				result += chunk;
				chunk = id+",";
			}
			result += id+"\n";
		}
		return result;
	}
			
	/* ONE DIMENSION ARRAY
	public static function arrayToCSV(input:Array, lineWidth:Int):String
	{
		var result:String = "";
		var lineBreaker:Int = lineWidth;
		for each(var entry:uint in input)
		{
			result += entry+",";
			if(--lineBreaker == 0)
			{
				result += "\n";
				lineBreaker = lineWidth;
			}
		}
		return result;
	}
	*/
	
	private static function csvToArray(input:String, lineWidth:Int):Array<Array<Int>>
	{
		var result:Array<Array<Int>> = new Array<Array<Int>>();
		var rows:Array<String> = input.split("\n");
		var row:String;
		for (row in rows)
		{
			var resultRow:Array<Int> = new Array<Int>();
			var entries:Array<String> = row.split(",");
			var entry:String;
			for (entry in entries)
				resultRow.push(Std.parseInt(entry)); //convert to uint
			result.push(resultRow);
		}
		return result;
	}
	
	private static function base64ToArray(chunk:String, lineWidth:Int, compressed:Bool):Array<Array<Int>>
	{
		var result:Array<Array<Int>> = new Array<Array<Int>>();
		var data:ByteArray = base64ToByteArray(chunk);
		if(compressed)
			data.uncompress();
		data.endian = Endian.LITTLE_ENDIAN;
		while(data.position < data.length)
		{
			var resultRow:Array<Int> = new Array<Int>();
			var i:Int;
			for (i in 0...lineWidth)
				resultRow.push(data.readInt());
			result.push(resultRow);
		}
		return result;
	}
	
	private static inline var BASE64_CHARS:String = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
	
	private static function base64ToByteArray(data:String):ByteArray 
	{
		var output:ByteArray = new ByteArray();
		//initialize lookup table
		var lookup:Array<Int> = new Array<Int>();
		var c:Int;
		for (c in 0...BASE64_CHARS.length)
			lookup[BASE64_CHARS.charCodeAt(c)] = c;
		
		var i:Int = 0;
		while (i < data.length - 3) 
		{
			//read 4 bytes and look them up in the table
			var a0:Int = lookup[data.charCodeAt(i)];
			var a1:Int = lookup[data.charCodeAt(i + 1)];
			var a2:Int = lookup[data.charCodeAt(i + 2)];
			var a3:Int = lookup[data.charCodeAt(i + 3)];
		
			// convert to and write 3 bytes
			if(a1 < 64)
				output.writeByte((a0 << 2) + ((a1 & 0x30) >> 4));
			if(a2 < 64)
				output.writeByte(((a1 & 0x0f) << 4) + ((a2 & 0x3c) >> 2));
			if(a3 < 64)
				output.writeByte(((a2 & 0x03) << 6) + a3);
			
			i += 4;
		}
		
		// Rewind & return decoded data
		output.position = 0;
		return output;
	}
}