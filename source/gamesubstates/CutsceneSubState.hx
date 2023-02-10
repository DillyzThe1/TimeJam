package gamesubstates;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSubState;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flxanimate.FlxAnimate;
import flxanimate.frames.FlxAnimateFrames;
import managers.MusicManager;
import openfl.utils.Assets;

class CutsceneSubState extends FlxSubState
{
	public static var nextCutscene:String = "cutscene 1";
	public static var nextOffset:FlxPoint = FlxPoint.get(-800, -500);

	var doneEvents:Array<Int> = new Array<Int>();

	var cutscene:FlxAnimate;

	var newCam:FlxCamera;

	var camTween:FlxTween;
	var endOnComplete:Bool = false;

	public override function create()
	{
		super.create();

		#if discord_presence
		managers.DiscordManager.setStatus('Exploring ${gamestates.PlayState.levelName}', 'In Cutscene');
		#end

		trace("hi");
		newCam = new FlxCamera();
		newCam.bgColor.alpha = 0;
		FlxG.cameras.add(newCam, false);
		newCam.zoom = 1.45;

		switch (nextCutscene)
		{
			case "cutscene 1":
				FlxG.sound.cache(Paths.music("cutscene_generic"));
				FlxG.sound.cache(Paths.sound("guhverb"));
				FlxG.sound.cache(Paths.sound("scratch"));
				FlxG.sound.cache(Paths.sound("blanket"));
		}

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
		MusicManager.play("cutscene_generic", 105, 0.1);
		FlxG.sound.music.fadeIn(0.25, 0.1, 0.775);
		endOnComplete = true;
	}

	function doCamEvent(zoom:Float, frameEnd:Int, ?ease:EaseFunction)
	{
		doneEvents.push(cutscene.anim.curFrame);

		if (camTween != null)
		{
			camTween.cancel();
			camTween.destroy();
		}
		camTween = FlxTween.tween(newCam, {zoom: zoom}, (frameEnd - cutscene.anim.curFrame) / cutscene.anim.framerate, {ease: ease});
	}

	public override function update(e:Float)
	{
		super.update(e);

		if (FlxG.keys.justPressed.ENTER || (endOnComplete && cutscene.anim.finished))
			skipCutscene();

		if (cutscene != null && cutscene.anim != null && !doneEvents.contains(cutscene.anim.curFrame))
			switch (nextCutscene)
			{
				case "cutscene 1":
					switch (cutscene.anim.curFrame)
					{
						case 1:
							doCamEvent(1.65, 20, FlxEase.cubeInOut);
						case 74:
							if (camTween != null)
							{
								camTween.cancel();
								camTween.destroy();
							}
							newCam.zoom += 0.075;
							doneEvents.push(cutscene.anim.curFrame);
						case 76:
							MusicManager.forceStop();
							FlxG.sound.play(Paths.sound("guhverb"), 2.5);
							FlxG.sound.play(Paths.sound("scratch"), 0.85);
							newCam.zoom = 2;
							doCamEvent(1.8, 90, FlxEase.cubeOut);
						case 94:
							FlxG.sound.play(Paths.sound("blanket"), 1);
							doneEvents.push(cutscene.anim.curFrame);
						case 96:
							doCamEvent(1.325, 108, FlxEase.cubeInOut);
					}
			}
	}

	public function skipCutscene()
	{
		trace("bye");
		if (camTween != null)
		{
			camTween.cancel();
			camTween.destroy();
			camTween = null;
		}
		FlxG.cameras.remove(newCam, false);
		remove(cutscene);

		if (Std.isOfType(cutscene.frames, FlxAnimateFrames))
			for (img in cast(cutscene.frames, FlxAnimateFrames).parents)
				if (img != null)
				{
					img.bitmap.dispose();
					img.destroy();
					img = null;
				}

		cutscene.destroy();
		cutscene = null;
		newCam.destroy();
		newCam = null;

		#if discord_presence
		managers.DiscordManager.setStatus('Exploring ${gamestates.PlayState.levelName}', 'In Game');
		#end
		close();
	}
}
