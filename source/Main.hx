package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import gamestates.TitleScreenState;
import gamestates.UnsupportedPlatformState;
import managers.MusicManager;
import managers.PlayerPreferenceManager;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public static var initState:Class<FlxState> = TitleScreenState;

	public function new()
	{
		super();

		#if html5
		initState = UnsupportedPlatformState;
		#end

		PlayerPreferenceManager.load();

		addChild(new FlxGame(1280, 720, initState, #if desktop 120, 120 #else 60, 60 #end, true, #if !desktop true #else false #end));
		addChild(new FPS(0, 0, FlxColor.WHITE));

		FlxG.sound.volume = 0.5;
		FlxG.autoPause = false;
	}
}
