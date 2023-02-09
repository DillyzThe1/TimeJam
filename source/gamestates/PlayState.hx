package gamestates;

import flixel.FlxG;
import objects.TMXLevel;

class PlayState extends TJState
{
	public var lvl:TMXLevel;

	override public function create()
	{
		super.create();

		lvl = new TMXLevel(Paths.tmx("the fred"));

		add(lvl.bgGroup);
		add(lvl.sprGroup);
		add(lvl.objGroup);
		add(lvl.fgGroup);
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new TitleScreenState());
	}
}
