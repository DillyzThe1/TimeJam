package gamestates;

import flixel.FlxG;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import gamesubstates.CutsceneSubState;
import objects.TMXLevel;

class PlayState extends TJState
{
	public var lvl:TMXLevel;

	override public function create()
	{
		super.create();

		lvl = new TMXLevel(Paths.tmx("tutorial"));

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

		var controls:Array<Bool> = [
			FlxG.keys.pressed.LEFT,
			FlxG.keys.pressed.RIGHT,
			FlxG.keys.pressed.UP,
			FlxG.keys.pressed.DOWN
		];
		for (i in 0...controls.length)
			if (controls[i])
				switch (i)
				{
					case 0:
						targetObject.x -= 5;
					case 1:
						targetObject.x += 5;
					case 2:
						targetObject.y -= 5;
					case 3:
						targetObject.y += 5;
				}

		zoomMAIN = FlxG.keys.pressed.SPACE ? 0.2 : 1;
	}

	override function destroy()
	{
		lvl.bgGroup.destroy();
		lvl.bgGroup = null;
		lvl.sprGroup.destroy();
		lvl.sprGroup = null;
		lvl.objGroup.destroy();
		lvl.objGroup = null;
		lvl.fgGroup.destroy();
		lvl.fgGroup = null;
		lvl = null;
		super.destroy();
	}

	override function closeSubState()
	{
		@:privateAccess
		var subname:String = Type.getClassName(Type.getClass(subState));
		trace("closing sub " + subname);

		switch (subname)
		{
			case "gamesubstates.CutsceneSubState":
				camHUD.flash(FlxColor.BLACK);
		}

		super.closeSubState();
	}
}
