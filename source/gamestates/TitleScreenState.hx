package gamestates;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import gamestates.menus.MainMenuState;
import managers.MusicManager;
import objects.ArcahicCrystal.ArchaicCrystal;
import objects.MenuButton.ButtonTypes;
import objects.MenuButton;
import openfl.Lib;

using TJUtil;

class TitleScreenState extends TJState
{
	var bg:FlxSprite;
	var logoSpr:FlxSprite;
	var textSpr:FlxSprite;
	var buttons:Array<ButtonTypes> = [PLAY, OPTIONS, ISSUES, QUIT];

	var bgTween:FlxTween;
	var logoTween:FlxTween;

	var ogBgY:Float = 0;
	var ogLogoY:Float = 0;

	var menuButtons:FlxTypedSpriteGroup<MenuButton>;

	var creditsText:FlxTypeText;
	var versText:FlxText;

	public override function create()
	{
		super.create();

		#if discord_presence
		managers.DiscordManager.setStatus(null, 'Title Screen');
		#end

		MusicManager.play("menu_main", 174, 1);

		bg = new FlxSprite().loadGraphic(Paths.image('bg'));
		bg.screenCenter();
		add(bg);
		ogBgY = bg.y;

		logoSpr = new FlxSprite().loadGraphic(Paths.image('glowy logo'));
		logoSpr.screenCenter();
		add(logoSpr);
		ogLogoY = logoSpr.y;

		textSpr = new FlxSprite(0, 590);
		textSpr.frames = Paths.sparrowv2("press enter");
		textSpr.animation.addByPrefix("begin", "press enter begin", 24, false, false, false);
		textSpr.animation.addByIndices("static", "press enter static", [1], "", 24, true, false, false);
		textSpr.animation.addByPrefix("vanish", "press enter vanish", 24, false, false, false);
		textSpr.screenCenter(X);

		creditsText = new FlxTypeText(0, FlxG.height * 0.9, 0, "", 24, true);
		creditsText.borderSize = 2;
		creditsText.borderColor = FlxColor.BLACK;
		creditsText.borderStyle = FlxTextBorderStyle.OUTLINE;
		creditsText.alignment = CENTER;
		creditsText.resetText("A game by DillyzThe1 & Impostor5875.");
		add(creditsText);

		versText = new FlxText(10, FlxG.height * 0.965, 0, "TimeJam v0.5.0-HaxeJam", 16, true);
		versText.borderSize = 2;
		versText.borderColor = FlxColor.BLACK;
		versText.borderStyle = FlxTextBorderStyle.OUTLINE;
		versText.alignment = CENTER;
		add(versText);

		textSpr.animation.finishCallback = function(n:String)
		{
			if (n == "begin")
			{
				textSpr.animation.play("static", true);
				textSpr.visible = true;
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

		if (MusicManager.exists())
			FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume);

		menuButtons = new FlxTypedSpriteGroup<MenuButton>();
		add(menuButtons);

		for (i in 0...buttons.length)
		{
			var button:MenuButton = new MenuButton(0, 0, buttons[i]);
			button.screenCenter(X);
			button.screenCenter(Y);
			button.x += button.getOff_X();
			button.y += 1500 + ofofofofofofoofoffofofofofoofoffoofofoffoofofofoffofoofofoffofooofofosetfofofofoofofosetofofofofofofoset * 0.85;
			menuButtons.add(button);
			add(button.hitbox);
		}
	}

	var totalElapsed:Float = 0;
	var logoElapsed:Float = 4.5;

	// var lastStep:Int = -1;
	var fastStep:Int = -1;
	var lastBeat:Int = -1;

	var plusThis:Float = 0;

	var menuActive:Bool = false;

	var logoScalingAllowed:Bool = false;

	var logoScales:Array<Float> = [0.645, 0.65, 0.655, 0.7, 1];

	var inputAllowed:Bool = true;

	var ofofofofofofoofoffofofofofoofoffoofofoffoofofofoffofoofofoffofooofofosetfofofofoofofosetofofofofofofoset:Int = 60;

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		totalElapsed += elapsed;
		creditsText.screenCenter(X);

		// lastStep = MusicManager.currentStep;
		lastBeat = MusicManager.currentBeat;
		MusicManager.updatePosition();

		if (lastBeat != MusicManager.currentBeat && lastBeat % 2 == 0)
		{
			plusThis += 25;
			if (logoScalingAllowed)
				logoSpr.scale.x = logoScales[3];
		}

		if (plusThis > 1.155)
			plusThis = FlxMath.lerp(plusThis, 1.15, clampFloat(elapsed * 10 * (120 / FlxG.drawFramerate), 0.01, 0.9));
		if (logoScalingAllowed && (logoSpr.scale.x > logoScales[2] || logoSpr.scale.x < logoScales[0]))
			logoSpr.scale.x = logoSpr.scale.y = FlxMath.lerp(logoSpr.scale.x, logoScales[1],
				clampFloat(elapsed * 3.5 * (120 / FlxG.drawFramerate), 0.01, 0.9));

		bg.angle += elapsed * (1.15 + plusThis);

		if (logoScalingAllowed)
		{
			logoElapsed += elapsed;
			logoSpr.offset.y = (Math.sin(logoElapsed) * 35) * logoScales[4];
			logoSpr.offset.x = ((Math.cos(logoElapsed) * 25) + 30) * logoScales[4];
			logoSpr.angle = (Math.cos(logoElapsed) * 2.5) + 2.5;
		}

		if (FlxG.keys.justPressed.ESCAPE && menuActive && inputAllowed)
		{
			creditsText.erase(0.0125, true);
			inputAllowed = false;
			menuActive = false;
			logoScalingAllowed = false;
			logoElapsed = 0;
			if (MusicManager.exists())
				FlxG.sound.music.fadeIn(0.5, 0.75, 1);
			textSpr.animation.play("begin", true);
			textSpr.visible = true;
			textSpr.offset.x = 0;
			textSpr.offset.y = 37;

			if (bgTween != null)
			{
				bgTween.cancel();
				bgTween.destroy();
			}
			FlxTween.tween(bg, {y: ogBgY}, 0.75, {ease: FlxEase.cubeOut});
			menuActive = false;
			logoScalingAllowed = false;
			logoElapsed = 0;

			if (logoTween != null)
			{
				logoTween.cancel();
				logoTween.destroy();
			}
			FlxTween.tween(logoSpr, {
				y: ogLogoY,
				"scale.x": 0.65,
				"scale.y": 0.65,
				"offset.x": 0,
				"offset.y": 0,
				angle: 0
			}, 0.75, {
				ease: FlxEase.cubeOut,
				onComplete: function(t:FlxTween)
				{
					logoScalingAllowed = inputAllowed = true;
					logoScales = [0.645, 0.65, 0.655, 0.7, 1];
				}
			});
		}

		if (FlxG.keys.justPressed.ENTER && !menuActive && inputAllowed)
		{
			inputAllowed = false;
			menuActive = true;
			logoScalingAllowed = false;
			logoElapsed = 0;
			if (MusicManager.exists())
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
			FlxTween.tween(bg, {y: ogBgY - 230 + ofofofofofofoofoffofofofofoofoffoofofoffoofofofoffofoofofoffofooofofosetfofofofoofofosetofofofofofofoset},
				0.75, {ease: FlxEase.cubeOut});

			// vsc please stop trolling me
			if (logoTween != null)
			{
				logoTween.cancel();
				logoTween.destroy();
			}
			FlxTween.tween(logoSpr, {
				y: ogLogoY - 230 + ofofofofofofoofoffofofofofoofoffoofofoffoofofofoffofoofofoffofooofofosetfofofofoofofosetofofofofofofoset,
				"scale.x": 0.25,
				"scale.y": 0.25,
				"offset.x": 0,
				"offset.y": 0,
				angle: 0
			}, 0.75, {
				ease: FlxEase.cubeOut,
				onComplete: function(t:FlxTween)
				{
					logoScalingAllowed = inputAllowed = true;
					logoScales = [0.245, 0.25, 0.255, 0.3, 0.5];
					creditsText.start(0.02, true);
				}
			});
		}

		if (FlxG.mouse.justPressed && menuActive)
			for (mb in menuButtons)
				if (mb.hovering && mb.enabled)
				{
					// no need for fancy stuff
					if (mb.getType() == ISSUES)
					{
						FlxG.openURL("https://github.com/DillyzThe1/TimeJam/issues");
						break;
					}

					// mb.forcePosition = true;

					creditsText.erase(0.0125, true);
					inputAllowed = false;
					menuActive = false;
					logoScalingAllowed = false;
					logoElapsed = 0;

					FlxG.camera.flash(FlxColor.WHITE, 1.15);
					FlxG.sound.play(Paths.sound("select"), 1.15);

					if (MusicManager.exists())
						FlxG.sound.music.fadeOut(0.5, mb.getType() == OPTIONS ? 0.75 : 0);

					if (bgTween != null)
					{
						bgTween.cancel();
						bgTween.destroy();
					}
					FlxTween.tween(bg, {alpha: 0}, 0.75, {ease: FlxEase.cubeOut});

					if (logoTween != null)
					{
						logoTween.cancel();
						logoTween.destroy();
					}
					FlxTween.tween(logoSpr, {
						"scale.x": 0.25,
						"scale.y": 0.25,
						"offset.x": 0,
						"offset.y": 0,
						angle: 0,
						alpha: 0
					}, 0.75, {
						ease: FlxEase.cubeOut,
						onComplete: function(t:FlxTween)
						{
							logoScalingAllowed = inputAllowed = true;
							logoScales = [0.245, 0.25, 0.255, 0.3, 0.5];
						}
					});
					FlxTween.tween(versText, {
						alpha: 0
					}, 0.75, {
						ease: FlxEase.cubeOut
					});

					new FlxTimer().start(1.25, function(bruh:FlxTimer)
					{
						switch (mb.getType())
						{
							case PLAY:
								for (i in 0...ArchaicCrystal.crystalsCollected.length)
									ArchaicCrystal.crystalsCollected.pop();
								for (i in 0...PlayState.flags.length)
									PlayState.flags.pop();
								PlayState.seenOpeningCutscene = false;
								ArchaicCrystal.lastAdded = -1;
								FlxG.switchState(new PlayState());
							#if sys
							case QUIT:
								trace("funny mailbox prank");
								Sys.exit(0);
							#end
							default:
								FlxG.switchState(new TitleScreenState());
						}
					});
					break;
				}

		menuButtons.sort(mbsort);

		for (mb in menuButtons)
		{
			// just bc i hate the formatting
			var off:Float = ((menuActive || mb.forcePosition) ? mb.getOff_Y() : 1500);
			off += ofofofofofofoofoffofofofofoofoffoofofoffoofofofoffofoofofoffofooofofosetfofofofoofofosetofofofofofofoset * 0.7;
			mb.y = FlxMath.lerp(FlxG.height / 2 - mb.height / 2 + off, mb.y,
				(elapsed * #if html5 55 #else 114 #end / (FlxG.updateFramerate / 60)).clampFloat(0.01, 0.99));
		}
	}

	function mbsort(idk:Int, b1:MenuButton, b2:MenuButton)
	{
		return FlxSort.byValues(FlxSort.ASCENDING, b1.hovering ? 1 : -1, 0);
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
		bg = null;
		logoSpr.destroy();
		logoSpr = null;
		textSpr.destroy();
		textSpr = null;
		if (bgTween != null)
		{
			bgTween.cancel();
			bgTween.destroy();
			bgTween = null;
		}
		if (logoTween != null)
		{
			logoTween.cancel();
			logoTween.destroy();
			logoTween = null;
		}
		super.destroy();
	}
}
