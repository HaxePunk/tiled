package haxepunk.tmx;

/**
 *  An ordered hash used by TmxPropertySet for storing and accessing custom properties.
 */
class TmxOrderedHash<T>
{
	var _keys:Array<String>;
#if haxe3
	var _map:Map<String, T>;
#else
	var _map:Hash<T>;
#end

	/**
	 *  Constructor.
	 */
	public function new()
	{
		_keys = new Array<String>();
#if haxe3
		_map = new Map<String, T>();
#else
		_map = new Hash<T>();
#end
	}

	/**
	 *  Maps a key to a value
	 *  @param key - Name of this value
	 *  @param value - Value to be stored at the name.
	 */
	public inline function set(key:String, value:T)
	{
		if (!_map.exists(key)) _keys.push(key);
		_map.set(key, value);
	}

	/**
	 *  Removes a value by name.
	 *  @param key - The key of the value to remove.
	 *  @return Bool True if removed.
	 */
	public inline function remove(key:String) : Bool
	{
		_keys.remove(key);
		return _map.remove(key);
	}

	/**
	 *  Checks if a key exists.
	 *  @param key - The key to check for.
	 *  @return Bool True if exists.
	 */
	public inline function exists(key:String):Bool return _map.exists(key);

	/**
	 *  Gets a value by it's key.
	 *  @param key - The key of the value to retrieve.
	 *  @return T The value referenced by the key.
	 */
	public inline function get(key:String):T return _map.get(key);

	public function iterator():Iterator<T>
	{
		var _keys_itr = _keys.iterator();
		var __map = _map;
		return {
			next: function() { return __map.get(_keys_itr.next()); },
			hasNext: _keys_itr.hasNext
		}
	}

	public function keys()
	{
		return _keys.iterator();
	}

	public function toString()
	{
		var __map = _map;
		var pairs = Lambda.map(_keys,
			function(x:String)
			{
				return x + ' => ' + __map.get(x);
			}
		);
		return  "{" + pairs.join(', ') + "}";
	}
}
