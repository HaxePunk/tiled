package haxepunk.tmx;

/**
 *  A lightweight 4 component vector.
 */
class TmxVec4
{
	/**
	 *  X position.
	 */
	public var x:Float;

	/**
	 *  Y position.
	 */
	public var y:Float;

	/**
	 *  Width.
	 */
	public var width:Float;

	/**
	 *  Height.
	 */
	public var height:Float;

	/**
	 *  Constructor.
	 *  @param x - x position.
	 *  @param y - y position.
	 *  @param width - width.
	 *  @param height - height.
	 */
	public function new(x:Float, y:Float, width:Float, height:Float)
	{
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

}
