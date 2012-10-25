HaxePunk Tiled
==============

To use this as a background image simply create a new instance of TmxEntity.

    public function createMap(mapData:String)
    {
      // create the map, set the assets in your nmml file to bytes
      var e = new TmxEntity("maps/mylevel.tmx");

      // load layers named bottom, main, top with the appropriate tileset
      e.loadGraphic("gfx/tileset.png", ["bottom", "main", "top"]);

      // loads a grid layer named collision and sets the entity type to walls
      e.loadMask("collision", "walls");

      add(e);
    }