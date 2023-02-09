package gamesubstates;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxTimer;
import flxanimate.FlxAnimate;
import openfl.utils.Assets;

class CutsceneSubState extends FlxSubState
{
	public static var nextCutscene:String = "cutscene 1";
	public static var nextOffset:FlxPoint = FlxPoint.get(-800, -450);

	var cutscene:FlxAnimate;

	var newCam:FlxCamera;

	public override function create()
	{
		super.create();
		trace("hi");
		newCam = new FlxCamera();
		newCam.bgColor.alpha = 0;
		FlxG.cameras.add(newCam, false);
		newCam.zoom = 1.45;

		cutscene = new FlxAnimate(nextOffset.x, nextOffset.y, Paths.texAtlas("cutscenes/" + nextCutscene));
		cutscene.anim.addBySymbol("play", "CUTSCENE", 24, false, 0, 0);
		// cutscene.anim.addByAnimIndices("static", [0], 24);
		cutscene.antialiasing = false;

		// cutscene.anim.play("static", true, false, 0);
		add(cutscene);

		// new FlxTimer().start(1.5, function(t:FlxTimer)
		// {
		cutscene.cameras = [newCam];
		play();
		// });
	}

	public function play()
	{
		trace("aaaa");
		cutscene.anim.play("play", true, false, 0);
		/*cutscene.anim.addCallbackTo("play", function()
			{
				
		});*/
	}

	public override function update(e:Float)
	{
		super.update(e);

		if (FlxG.keys.justPressed.ENTER)
			skipCutscene();
	}

	public function skipCutscene()
	{
		trace("bye");
		FlxG.cameras.remove(newCam, false);
		remove(cutscene);
		cutscene.destroy();
		newCam.destroy();
		Assets.cache.clear(Paths.texAtlas("cutscenes/"));
		close();
	}
}
