package;

import flixel.FlxGame;
import flixel.util.FlxColor;
import gamestates.TitleScreenState;
import openfl.display.FPS;
import openfl.display.Sprite;

class Main extends Sprite
{
	public function new()
	{
		super();
		addChild(new FlxGame(0, 0, TitleScreenState, #if desktop 120, 120 #else 60, 60 #end, true, #if !desktop true #else false #end));
		addChild(new FPS(0, 0, FlxColor.WHITE));
	}
}
