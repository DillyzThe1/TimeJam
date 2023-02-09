package;

import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import gamestates.TitleScreenState;
import managers.MusicManager;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		FlxSprite.defaultAntialiasing = true;

		addChild(new FlxGame(0, 0, TitleScreenState, #if desktop 120, 120 #else 60, 60 #end, true, #if !desktop true #else false #end));
		addChild(new FPS(0, 0, FlxColor.WHITE));

		FlxG.sound.volume = 0.5;
		FlxG.autoPause = false;

		MusicManager.play("menu_main", 174, 1);
	}
}
