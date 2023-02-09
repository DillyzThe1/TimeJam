package gamestates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import gamestates.menus.MainMenuState;
import managers.MusicManager;

class TitleScreenState extends TJState
{
	var bg:FlxSprite;
	var logoSpr:FlxSprite;
	var textSpr:FlxSprite;

	var bgTween:FlxTween;
	var logoTween:FlxTween;

	public override function create()
	{
		super.create();

		MusicManager.play("menu_main", 174, 1);

		bg = new FlxSprite().loadGraphic(Paths.image('bg'));
		bg.screenCenter();
		add(bg);

		logoSpr = new FlxSprite().loadGraphic(Paths.image('glowy logo'));
		logoSpr.screenCenter();
		add(logoSpr);

		textSpr = new FlxSprite(0, 590);
		textSpr.frames = Paths.sparrowv2("press enter");
		textSpr.animation.addByPrefix("begin", "press enter begin", 24, false, false, false);
		textSpr.animation.addByIndices("static", "press enter static", [1], "", 24, true, false, false);
		textSpr.animation.addByPrefix("vanish", "press enter vanish", 24, false, false, false);
		textSpr.screenCenter(X);

		textSpr.animation.finishCallback = function(n:String)
		{
			if (n == "begin")
			{
				textSpr.animation.play("static", true);
				textSpr.offset.x = 0;
				textSpr.offset.y = 0;
			}
			else if (n == "vanish")
			{
				textSpr.animation.play("static", true);
				textSpr.visible = false;
				textSpr.offset.x = 0;
				textSpr.offset.y = 0;
			}
		};

		textSpr.animation.play("begin", true);
		textSpr.offset.x = 0;
		textSpr.offset.y = 37;
		add(textSpr);

		// intro stuff
		bg.alpha = logoSpr.alpha = 0;
		logoSpr.scale.set(0.35, 0.35);

		bgTween = FlxTween.tween(bg, {alpha: 1}, 0.65, {ease: FlxEase.cubeInOut});
		logoTween = FlxTween.tween(logoSpr, {
			alpha: 1,
			"scale.x": 0.65,
			"scale.y": 0.65,
			"offset.y": Math.sin(logoElapsed) * 35,
			"offset.x": (Math.cos(logoElapsed) * 25) + 30,
			"angle": (Math.cos(logoElapsed) * 2.5) + 2.5
		}, 0.35, {
			ease: FlxEase.cubeOut,
			onComplete: function(t:FlxTween)
			{
				logoScalingAllowed = true;
			}
		});

		if (FlxG.sound.music != null)
			FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume);
	}

	var totalElapsed:Float = 0;
	var logoElapsed:Float = 4.5;

	// var lastStep:Int = -1;
	var fastStep:Int = -1;
	var lastBeat:Int = -1;

	var plusThis:Float = 0;

	var hasPressed:Bool = false;

	var logoScalingAllowed:Bool = false;

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		totalElapsed += elapsed;

		// lastStep = MusicManager.currentStep;
		lastBeat = MusicManager.currentBeat;
		MusicManager.updatePosition();

		if (lastBeat != MusicManager.currentBeat && lastBeat % 2 == 0)
		{
			plusThis += 25;
			if (logoScalingAllowed)
				logoSpr.scale.x = 0.7;
		}

		if (plusThis > 1.155)
			plusThis = FlxMath.lerp(plusThis, 1.15, clampFloat(elapsed * 10 * (120 / FlxG.drawFramerate), 0.01, 0.9));
		if (logoScalingAllowed && (logoSpr.scale.x > 0.655 || logoSpr.scale.x < 0.645))
			logoSpr.scale.x = logoSpr.scale.y = FlxMath.lerp(logoSpr.scale.x, 0.65, clampFloat(elapsed * 3.5 * (120 / FlxG.drawFramerate), 0.01, 0.9));

		bg.angle += elapsed * (1.15 + plusThis);

		if (logoScalingAllowed)
		{
			logoElapsed += elapsed;
			logoSpr.offset.y = Math.sin(logoElapsed) * 35;
			logoSpr.offset.x = (Math.cos(logoElapsed) * 25) + 30;
			logoSpr.angle = (Math.cos(logoElapsed) * 2.5) + 2.5;
		}

		if (FlxG.keys.justPressed.ENTER && !hasPressed)
		{
			hasPressed = true;
			logoScalingAllowed = false;
			logoElapsed = 0;
			if (FlxG.sound.music != null)
				FlxG.sound.music.fadeOut(0.5, 0.75);
			FlxG.camera.flash(FlxColor.WHITE, 1.15);
			FlxG.sound.play(Paths.sound("select"), 1.15);
			textSpr.animation.play("vanish", true);
			textSpr.offset.x = 31;
			textSpr.offset.y = 0;

			if (bgTween != null)
			{
				bgTween.cancel();
				bgTween.destroy();
			}
			FlxTween.tween(bg, {alpha: 0}, 0.5, {ease: FlxEase.cubeInOut});

			// vsc please stop trolling me
			if (logoTween != null)
			{
				logoTween.cancel();
				logoTween.destroy();
			}
			FlxTween.tween(logoSpr, {
				alpha: 0,
				"scale.x": 0.1,
				"scale.y": 0.1,
				"offset.x": 0,
				"offset.y": 0,
				"angle": 0
			}, 0.75, {ease: FlxEase.cubeOut});

			new FlxTimer().start(1.5, function(bruh:FlxTimer)
			{
				FlxG.switchState(new MainMenuState());
			});
		}
	}

	function clampFloat(val:Float, min:Float, max:Float)
	{
		if (val > max)
			return max;
		if (val < min)
			return min;
		return val;
	}

	override function destroy()
	{
		bg.destroy();
		logoSpr.destroy();
		textSpr.destroy();
		if (bgTween != null)
		{
			bgTween.cancel();
			bgTween.destroy();
		}
		if (logoTween != null)
		{
			logoTween.cancel();
			logoTween.destroy();
		}
		super.destroy();
	}
}
