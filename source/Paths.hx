package;

import flixel.graphics.frames.FlxAtlasFrames;

enum PathAssetType
{
	TXT;
	JSON;
	IMAGE;
	IMAGEJSON;
	IMAGETXT;
	XML;
	MUSIC;
	SOUND;
	FONT_TTF;
	FONT_OTF;
	TEXTUREATLAS;
}

// common file paths so you only have to type simplistic strings out. fun!
class Paths
{
	inline private static function asset(path:String, assetType:PathAssetType)
	{
		var subFolder:String;
		var fileExtension:String;

		switch (assetType)
		{
			case JSON:
				subFolder = 'data';
				fileExtension = 'json';
			case IMAGE:
				subFolder = 'images';
				fileExtension = 'png';
			case IMAGEJSON:
				subFolder = 'images';
				fileExtension = 'json';
			case IMAGETXT:
				subFolder = 'images';
				fileExtension = 'txt';
			case XML:
				subFolder = 'images';
				fileExtension = 'xml';
			case MUSIC:
				subFolder = 'music';
				fileExtension = #if web 'mp3' #else 'ogg' #end;
			case SOUND:
				subFolder = 'sounds';
				fileExtension = #if web 'mp3' #else 'ogg' #end;
			case FONT_TTF:
				subFolder = 'fonts';
				fileExtension = 'ttf';
			case FONT_OTF:
				subFolder = 'fonts';
				fileExtension = 'otf';
			case TEXTUREATLAS:
				subFolder = 'images';
				fileExtension = null;
			default:
				subFolder = 'data';
				fileExtension = 'txt';
		}
		return 'assets/$subFolder/$path${fileExtension != null ? '.$fileExtension' : ''}';
	}

	inline public static function text(path:String)
		return asset(path, TXT);

	inline public static function json(path:String)
		return asset(path, JSON);

	inline public static function image(path:String)
		return asset(path, IMAGE);

	inline public static function imagejson(path:String)
		return asset(path, IMAGEJSON);

	inline public static function imagetxt(path:String)
		return asset(path, IMAGETXT);

	inline public static function xml(path:String)
		return asset(path, XML);

	inline public static function music(path:String)
		return asset(path, MUSIC);

	inline public static function sound(path:String)
		return asset(path, SOUND);

	inline public static function font(path:String, ?trueTypeFont:Bool = true)
		return asset(path, trueTypeFont ? FONT_TTF : FONT_OTF);

	inline public static function sparrowv2(path:String)
		return FlxAtlasFrames.fromSparrow(image(path), xml(path));

	inline public static function texAtlas(path:String)
		return asset(path, TEXTUREATLAS);
}
