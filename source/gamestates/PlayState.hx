package gamestates;

import flixel.FlxG;
import gamesubstates.CutsceneSubState;
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

		if (FlxG.keys.justPressed.ONE)
			openSubState(new CutsceneSubState());
	}

	override function destroy()
	{
		lvl.bgGroup.destroy();
		lvl.sprGroup.destroy();
		lvl.objGroup.destroy();
		lvl.fgGroup.destroy();
		super.destroy();
	}
}
