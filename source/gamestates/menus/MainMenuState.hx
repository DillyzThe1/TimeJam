package gamestates.menus;

import flixel.FlxG;

class MainMenuState extends TJState
{
	override public function create()
	{
		super.create();
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new TitleScreenState());
	}
}
