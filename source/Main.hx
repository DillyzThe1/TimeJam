package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.util.FlxColor;
import gamestates.TitleScreenState;
import gamestates.UnsupportedPlatformState;
import managers.MusicManager;
import managers.PlayerDataManager;
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
		if (FlxG.onMobile)
			initState = UnsupportedPlatformState;
		#end

		PlayerPreferenceManager.load();
		PlayerDataManager.load(0);

		#if discord_presence
		managers.DiscordManager.initClient();
		#end

		addChild(new FlxGame(1280, 720, initState, #if desktop 120, 120 #else 60, 60 #end, true, #if !desktop true #else false #end));
		addChild(new FPS(0, 0, FlxColor.WHITE));

		#if !html5
		FlxG.sound.volume = 0.5;
		#end
		FlxG.autoPause = false;
	}
}
