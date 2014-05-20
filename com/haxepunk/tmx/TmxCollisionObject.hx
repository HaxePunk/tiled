package com.haxepunk.tmx;

import com.haxepunk.tmx.TmxVec4;

/**
 * ...
 * @author Jero
 */
class TmxCollisionObject extends TmxVec4
{
	public var type:String;
	public var radius:Int;
	public var polyPoints:Array<Float>;
	public function new(x:Float, y:Float, width:Float, height:Float, type:String = "box", radius:Int = 0, polyPoints:Array<Float> = null)
	{
		this.type = type;
		this.radius = radius;
		this.polyPoints = polyPoints;
		super(x, y, width, height);
	}
}