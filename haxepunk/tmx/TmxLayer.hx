/*******************************************************************************
 * Copyright (c) 2011 by Matt Tuttle (original by Thomas Jahn)
 * This content is released under the MIT License.
 * For questions mail me at heardtheword@gmail.com
 ******************************************************************************/
package haxepunk.tmx;

import flash.utils.ByteArray;
import flash.utils.Endian;
import haxe.xml.Fast;

/**
 *  A data class that represents a Tiled TileLayer.
 */
class TmxLayer
{
	/**
	 *  The parent map of this layer.
	 */
	public var map:TmxMap;

	/**
	 *  The name of this layer.
	 */
	public var name:String;

	/**
	 *  The x coordinate of the layer in tiles. Defaults to 0 and can not be changed in Tiled.
	 */
	public var x:Int;

	/**
	 *  The y coordinate of the layer in tiles. Defaults to 0 and can not be changed in Tiled.
	 */
	public var y:Int;

	/**
	 *  The width of the layer in tiles. Always the same as the map width for fixed-size maps.
	 */
	public var width:Int;

	/**
	 *  The height of the layer in tiles. Always the same as the map height for fixed-size maps.
	 */
	public var height:Int;

	/**
	 *  The opacity of the layer as a value from 0 to 1. Defaults to 1.
	 */
	public var opacity:Float;

	/**
	 *  Whether the layer is shown or hidden.  Defaults to true.
	 */
	public var visible:Bool;


	/**
	 *  A 2D array of the tile gids.  Indexed by [row][col].
	 */
	public var tileGIDs:Array<Array<Int>>;

	/**
	 *  The custom properties of this layer.
	 */
	public var properties:TmxPropertySet;
	
	/**
	 *  Constructor.
	 *  
	 *  @param source - The Xml.Fast node that represents this layer.
	 *  @param parent - The TmxMap this layer belongs to.
	 */
	public function new(source:Fast, parent:TmxMap)
	{
		properties = new TmxPropertySet();
		map = parent;
		name = source.att.name;
		x = (source.has.x) ? Std.parseInt(source.att.x) : 0;
		y = (source.has.y) ? Std.parseInt(source.att.y) : 0;
		width = Std.parseInt(source.att.width); 
		height = Std.parseInt(source.att.height); 
		visible = (source.has.visible && source.att.visible == "1") ? true : false;
		opacity = (source.has.opacity) ? Std.parseFloat(source.att.opacity) : 0;
		
		//load properties
		var node:Fast;
		for (node in source.nodes.properties)
			properties.extend(node);
		
		//load tile GIDs
		tileGIDs = [];
		var data:Fast = source.node.data;
		if (data != null)
		{
			var chunk:String = "";
			var data_encoding = "default";
			if (data.has.encoding)
			{
				data_encoding = data.att.encoding;
			}
			switch (data_encoding)
			{
				case "base64":
					chunk = data.innerData;
					var compressed:Bool = false;
					if (data.has.compression)
					{
						switch (data.att.compression)
						{
							case "zlib":
								compressed = true;
							default:
								throw "TmxLayer - data compression type not supported!";
						}
					}
					tileGIDs = base64ToArray(chunk, width, compressed);
				case "csv":
					chunk = data.innerData;
					tileGIDs = csvToArray(chunk);
				default:
					//create a 2dimensional array
					var lineWidth:Int = width;
					var rowIdx:Int = -1;
					for (node in data.nodes.tile)
					{
						//new line?
						if (++lineWidth >= width)
						{
							tileGIDs[++rowIdx] = new Array<Int>();
							lineWidth = 0;
						}
						var gid:Int = Std.parseInt(node.att.gid);
						tileGIDs[rowIdx].push(gid);
					}
			}
		}
	}
	
	/**
	 *  Exports this tileLayer to a comma separated value string.
	 *  
	 *  @param tileSet - An optional tileset that is used to validate the tile index's.
	 *  @return String
	 */
	public function toCsv(?tileSet:TmxTileSet):String
	{
		var max:Int = 0xFFFFFF;
		var offset:Int = 0;
		if (tileSet != null)
		{
			offset = tileSet.firstGID;
			max = tileSet.numTiles - 1;
		}
		var result:String = "";
		var row:Array<Int>;
		for (row in tileGIDs)
		{
			var id:Int = 0;
			for (id in row)
			{
				id -= offset;
				if (id < 0 || id > max)
					id = 0;
				result +=  id + ",";
			}
			result += id + "\n";
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
			if (--lineBreaker == 0)
			{
				result += "\n";
				lineBreaker = lineWidth;
			}
		}
		return result;
	}
	*/
	
	private static function csvToArray(input:String):Array<Array<Int>>
	{
		var result:Array<Array<Int>> = new Array<Array<Int>>();
		var rows:Array<String> = input.split("\n");
		var row:String;
		for (row in rows)
		{
			if (row == "") continue;
			var resultRow:Array<Int> = new Array<Int>();
			var entries:Array<String> = row.split(",");
			var entry:String;
			for (entry in entries)
				resultRow.push(Std.parseInt(entry)); //convert to int
			result.push(resultRow);
		}
		return result;
	}
	
	private static function base64ToArray(chunk:String, lineWidth:Int, compressed:Bool):Array<Array<Int>>
	{
		var result:Array<Array<Int>> = new Array<Array<Int>>();
		var data:ByteArray = base64ToByteArray(chunk);
		if (compressed)
		{
			#if (js && !format)
			throw "Need the format library to use compressed map on html5";
			#else 
			data.uncompress();
			#end
		}
			
		data.endian = Endian.LITTLE_ENDIAN;
		while (data.position < data.length)
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
		{
			lookup[BASE64_CHARS.charCodeAt(c)] = c;
		}
		
		var i:Int = 0;
		while (i < data.length - 3) 
		{
			// Ignore whitespace
			if (data.charAt(i) == " " || data.charAt(i) == "\n")
			{
				i++; continue;
			}
			
			//read 4 bytes and look them up in the table
			var a0:Int = lookup[data.charCodeAt(i)];
			var a1:Int = lookup[data.charCodeAt(i + 1)];
			var a2:Int = lookup[data.charCodeAt(i + 2)];
			var a3:Int = lookup[data.charCodeAt(i + 3)];
			
			// convert to and write 3 bytes
			if (a1 < 64)
				output.writeByte((a0 << 2) + ((a1 & 0x30) >> 4));
			if (a2 < 64)
				output.writeByte(((a1 & 0x0f) << 4) + ((a2 & 0x3c) >> 2));
			if (a3 < 64)
				output.writeByte(((a2 & 0x03) << 6) + a3);
			
			i += 4;
		}
		
		// Rewind & return decoded data
		output.position = 0;
		return output;
	}
}
