package;


import lime.app.Config;
import lime.utils.AssetLibrary;
import lime.utils.AssetManifest;
import lime.utils.Assets;

#if sys
import sys.FileSystem;
#end

@:access(lime.utils.Assets)


@:keep @:dox(hide) class ManifestResources {
	
	
	public static var preloadLibraries:Array<AssetLibrary>;
	public static var preloadLibraryNames:Array<String>;
	
	
	public static function init (config:Config):Void {
		
		preloadLibraries = new Array ();
		preloadLibraryNames = new Array ();
		
		var rootPath = null;
		
		if (config != null && Reflect.hasField (config, "rootPath")) {
			
			rootPath = Reflect.field (config, "rootPath");
			
		}
		
		if (rootPath == null) {
			
			#if (ios || tvos || emscripten)
			rootPath = "assets/";
			#elseif (sys && windows && !cs)
			rootPath = FileSystem.absolutePath (haxe.io.Path.directory (#if (haxe_ver >= 3.3) Sys.programPath () #else Sys.executablePath () #end)) + "/";
			#else
			rootPath = "";
			#end
			
		}
		
		Assets.defaultRootPath = rootPath;
		
		#if (openfl && !flash && !display)
		openfl.text.Font.registerFont (__ASSET__OPENFL__font_monofonto_ttf);
		
		#end
		
		var data, manifest, library;
		
		data = '{"name":null,"assets":"aoy4:pathy35:graphics%2Fpreloader%2Fhaxepunk.pngy4:sizei21044y4:typey5:IMAGEy2:idR1y7:preloadtgoR0y36:graphics%2Fdebug%2Fconsole_pause.pngR2i213R3R4R5R7R6tgoR0y35:graphics%2Fdebug%2Fconsole_play.pngR2i242R3R4R5R8R6tgoR0y43:graphics%2Fdebug%2Fconsole_drawcall_add.pngR2i183R3R4R5R9R6tgoR0y37:graphics%2Fdebug%2Fconsole_hidden.pngR2i1216R3R4R5R10R6tgoR0y43:graphics%2Fdebug%2Fconsole_drawcall_all.pngR2i189R3R4R5R11R6tgoR0y35:graphics%2Fdebug%2Fconsole_logo.pngR2i21764R3R4R5R12R6tgoR0y37:graphics%2Fdebug%2Fconsole_output.pngR2i186R3R4R5R13R6tgoR0y35:graphics%2Fdebug%2Fconsole_step.pngR2i251R3R4R5R14R6tgoR0y36:graphics%2Fdebug%2Fconsole_debug.pngR2i242R3R4R5R15R6tgoR0y38:graphics%2Fdebug%2Fconsole_visible.pngR2i1275R3R4R5R16R6tgoR0y29:graphics%2Fdebug%2Fbutton.pngR2i248R3R4R5R17R6tgoR2i58088R3y4:FONTy9:classNamey27:__ASSET__font_monofonto_ttfR5y20:font%2Fmonofonto.ttfR6tgoR0y20:font%2Fmonofonto.fntR2i11598R3y4:TEXTR5R22R6tgoR0y20:font%2Fmonofonto.pngR2i19822R3R4R5R24R6tgoR0y19:graphics%2Fwall.pngR2i2520R3R4R5R25R6tgoR0y18:maps%2Fexample.tmxR2i659R3R23R5R26R6tgh","version":2,"libraryArgs":[],"libraryType":null}';
		manifest = AssetManifest.parse (data, rootPath);
		library = AssetLibrary.fromManifest (manifest);
		Assets.registerLibrary ("default", library);
		
		
		library = Assets.getLibrary ("default");
		if (library != null) preloadLibraries.push (library);
		else preloadLibraryNames.push ("default");
		
		
	}
	
	
}


#if !display
#if flash

@:keep @:bind #if display private #end class __ASSET__graphics_preloader_haxepunk_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__graphics_debug_console_pause_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__graphics_debug_console_play_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__graphics_debug_console_drawcall_add_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__graphics_debug_console_hidden_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__graphics_debug_console_drawcall_all_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__graphics_debug_console_logo_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__graphics_debug_console_output_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__graphics_debug_console_step_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__graphics_debug_console_debug_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__graphics_debug_console_visible_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__graphics_debug_button_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__font_monofonto_ttf extends null { }
@:keep @:bind #if display private #end class __ASSET__font_monofonto_fnt extends null { }
@:keep @:bind #if display private #end class __ASSET__font_monofonto_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__graphics_wall_png extends flash.display.BitmapData { public function new () { super (0, 0, true, 0); } }
@:keep @:bind #if display private #end class __ASSET__maps_example_tmx extends null { }
@:keep @:bind #if display private #end class __ASSET__manifest_default_json extends null { }


#elseif (desktop || cpp)

@:image("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/graphics/preloader/haxepunk.png") #if display private #end class __ASSET__graphics_preloader_haxepunk_png extends lime.graphics.Image {}
@:image("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/graphics/debug/console_pause.png") #if display private #end class __ASSET__graphics_debug_console_pause_png extends lime.graphics.Image {}
@:image("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/graphics/debug/console_play.png") #if display private #end class __ASSET__graphics_debug_console_play_png extends lime.graphics.Image {}
@:image("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/graphics/debug/console_drawcall_add.png") #if display private #end class __ASSET__graphics_debug_console_drawcall_add_png extends lime.graphics.Image {}
@:image("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/graphics/debug/console_hidden.png") #if display private #end class __ASSET__graphics_debug_console_hidden_png extends lime.graphics.Image {}
@:image("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/graphics/debug/console_drawcall_all.png") #if display private #end class __ASSET__graphics_debug_console_drawcall_all_png extends lime.graphics.Image {}
@:image("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/graphics/debug/console_logo.png") #if display private #end class __ASSET__graphics_debug_console_logo_png extends lime.graphics.Image {}
@:image("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/graphics/debug/console_output.png") #if display private #end class __ASSET__graphics_debug_console_output_png extends lime.graphics.Image {}
@:image("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/graphics/debug/console_step.png") #if display private #end class __ASSET__graphics_debug_console_step_png extends lime.graphics.Image {}
@:image("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/graphics/debug/console_debug.png") #if display private #end class __ASSET__graphics_debug_console_debug_png extends lime.graphics.Image {}
@:image("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/graphics/debug/console_visible.png") #if display private #end class __ASSET__graphics_debug_console_visible_png extends lime.graphics.Image {}
@:image("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/graphics/debug/button.png") #if display private #end class __ASSET__graphics_debug_button_png extends lime.graphics.Image {}
@:font("export/html5/obj/webfont/monofonto.ttf") #if display private #end class __ASSET__font_monofonto_ttf extends lime.text.Font {}
@:file("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/font/monofonto.fnt") #if display private #end class __ASSET__font_monofonto_fnt extends haxe.io.Bytes {}
@:image("/Users/maskedpixel/Development/haxe/libs/HaxePunk/assets/font/monofonto.png") #if display private #end class __ASSET__font_monofonto_png extends lime.graphics.Image {}
@:image("assets/graphics/wall.png") #if display private #end class __ASSET__graphics_wall_png extends lime.graphics.Image {}
@:file("assets/maps/example.tmx") #if display private #end class __ASSET__maps_example_tmx extends haxe.io.Bytes {}
@:file("") #if display private #end class __ASSET__manifest_default_json extends haxe.io.Bytes {}



#else

@:keep @:expose('__ASSET__font_monofonto_ttf') #if display private #end class __ASSET__font_monofonto_ttf extends lime.text.Font { public function new () { #if !html5 __fontPath = "font/monofonto"; #end name = "Monofonto-Regular"; super (); }}


#end

#if (openfl && !flash)

@:keep @:expose('__ASSET__OPENFL__font_monofonto_ttf') #if display private #end class __ASSET__OPENFL__font_monofonto_ttf extends openfl.text.Font { public function new () { var font = new __ASSET__font_monofonto_ttf (); src = font.src; name = font.name; super (); }}


#end
#end