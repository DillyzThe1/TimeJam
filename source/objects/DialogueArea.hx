package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.Assets;

using StringTools;

typedef DialogueInstance =
{
	var boxtype:String;
	var leftchar:String;
	var rightchar:String;
	var speaking:String;
	var expressionleft:String;
	var forceleft:Bool;
	var expressionright:String;
	var forceright:Bool;
	var clear:Bool;
	var clipname:String;
	var dialogue:String;
	var skip_prompt:Bool;
	var music_vol_mult:Float;
}

typedef DialogueData =
{
	var box:String;
	var bgAlpha:Float;
	var autoSkipFirst:Bool;
	var dialogue:Array<DialogueInstance>;
}

class DialogueArea extends FlxSpriteGroup
{
	public var bg:FlxSprite;
	public var dialogueBox:FlxSprite;
	public var dialogueData:DialogueData;

	public var dialogueText:FlxTypeText;

	public var introTween:FlxTween;

	public var dialogueIndex:Int = -1;

	public var dialogueSfx:FlxSound;

	var onComplete:() -> Void;

	// var ssssss:FlxSound;
	var leftSprite:FlxSprite;
	var rightSprite:FlxSprite;

	var lastchar_left:String = "";
	var lastchar_right:String = "";

	var lastchar_left_washidden:Bool = true;
	var lastchar_right_washidden:Bool = true;

	var closing:Bool = false;

	var allowInput:Bool = false;

	public function new(dialogueName:String, onComplete:() -> Void)
	{
		super();
		this.onComplete = onComplete;

		bg = new FlxSprite(-FlxG.width / 2, -FlxG.height / 2).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		bg.alpha = 0;

		dialogueBox = new FlxSprite();
		dialogueBox.frames = Paths.sparrowv2("dialogue-box");
		dialogueBox.animation.addByPrefix("none", "box default0000");
		dialogueBox.animation.addByPrefix("both", "box both0000");
		dialogueBox.animation.addByPrefix("left", "box left0000");
		dialogueBox.animation.addByPrefix("right", "box right0000");
		dialogueBox.animation.play("none", true);

		dialogueBox.screenCenter(X);
		dialogueBox.y = FlxG.height + dialogueBox.height + 100;

		dialogueBox.scale.set(1.3, 1.25);

		dialogueText = new FlxTypeText(0, 0, 0, "", 32, true);
		dialogueText.borderSize = 2;
		dialogueText.borderColor = FlxColor.BLACK;
		dialogueText.borderStyle = FlxTextBorderStyle.OUTLINE;
		dialogueText.visible = false;
		dialogueText.delay = 0.035;
		// ssssss = new FlxSound().loadEmbedded(Paths.sound("type"));
		// dialogueText.sounds = [ssssss];

		dialogueData = Json.parse(Assets.getText(Paths.json("dialogue/" + dialogueName)));
		dialogueSfx = new FlxSound().loadEmbedded(Paths.sound("dialogue continue"));

		cur = dialogueData.dialogue[0];

		add(bg);
		add(dialogueBox);
		add(dialogueText);

		FlxG.sound.music.fadeOut(1, 0.2);
		introTween = FlxTween.tween(this, {
			"bg.alpha": dialogueData.bgAlpha,
			"dialogueBox.y": FlxG.height - dialogueBox.height - 40,
			"dialogueBox.scale.x": 1,
			"dialogueBox.scale.y": 1
		}, 1.5, {
			ease: FlxEase.cubeInOut,
			onComplete: function(t:FlxTween)
			{
				if (dialogueData.autoSkipFirst)
					nextDialogue();
				else
					allowInput = true;
			}
		});
	}

	var dialogueSpaceLeft:Int = 75;
	var dialogueSpaceRight:Int = 75;
	var dialogueInProgress:Bool = false;

	var skipWhenDone:Bool = true;
	var cur:DialogueInstance;

	public function nextDialogue()
	{
		if (closing)
			return;
		allowInput = false;

		if (dialogueInProgress)
		{
			dialogueInProgress = false;
			dialogueText.skip();
			allowInput = true;
			return;
		}

		if (!skipWhenDone)
		{
			dialogueSfx.volume = FlxG.sound.volume;
			dialogueSfx.play(true, 0);
		}

		dialogueIndex++;

		if (dialogueIndex >= dialogueData.dialogue.length)
		{
			skipWhenDone = false;
			dialogueText.visible = false;
			if (introTween != null)
			{
				introTween.cancel();
				introTween.destroy();
			}

			if (leftSprite != null)
				leftSprite.visible = false;
			if (rightSprite != null)
				rightSprite.visible = false;

			FlxG.sound.music.fadeIn(1, FlxG.sound.music.volume, 0.4);
			introTween = FlxTween.tween(this, {
				"bg.alpha": 0,
				"dialogueBox.y": FlxG.height + dialogueBox.height + 100,
				"dialogueBox.scale.x": 1.3,
				"dialogueBox.scale.y": 1.25
			}, 1.5, {
				ease: FlxEase.cubeInOut,
				onComplete: function(t:FlxTween)
				{
					if (this.onComplete != null)
						this.onComplete();
				}
			});
			return;
		}

		cur = dialogueData.dialogue[dialogueIndex];
		dialogueText.visible = (cur.dialogue != "");
		if (dialogueText.visible && cur.dialogue != "__continue")
		{
			dialogueInProgress = true;
			@:privateAccess
			if (!cur.clear)
			{
				dialogueText._finalText = dialogueText.text + cur.dialogue;
				dialogueText._typing = false;
				dialogueText._erasing = false;
				dialogueText.paused = false;
				dialogueText._waiting = false;
				dialogueText._length = dialogueText.text.length;
			}
			else
				dialogueText.resetText(cur.dialogue);
			dialogueText.start(null, cur.clear, false, [], function()
			{
				dialogueInProgress = false;
			});
		}
		skipWhenDone = cur.skip_prompt;
		FlxG.sound.music.volume = 0.2 * cur.music_vol_mult;

		dialogueBox.animation.play(cur.boxtype.toLowerCase(), true);
		switch (cur.boxtype.toLowerCase())
		{
			case "none":
				dialogueSpaceLeft = 75;
				dialogueSpaceRight = 75;

				if (leftSprite != null)
					leftSprite.visible = false;
				if (rightSprite != null)
					rightSprite.visible = false;
			case "left":
				dialogueSpaceLeft = 275;
				dialogueSpaceRight = 75;

				if (leftSprite != null)
					leftSprite.visible = true;
				if (rightSprite != null)
					rightSprite.visible = false;

				checkCharacter(cur.leftchar, true);
			case "right":
				dialogueSpaceLeft = 25;
				dialogueSpaceRight = 75;

				// dialogueSpaceLeft = 75;
				// dialogueSpaceRight = 275;

				if (leftSprite != null)
					leftSprite.visible = false;
				if (rightSprite != null)
					rightSprite.visible = true;

				checkCharacter(cur.rightchar, false);
			case "both":
				dialogueSpaceLeft = dialogueSpaceRight = 275;

				if (leftSprite != null)
					leftSprite.visible = true;
				if (rightSprite != null)
					rightSprite.visible = true;

				checkCharacter(cur.leftchar, true);
				checkCharacter(cur.rightchar, false);

				dialogueText.alignment = cur.speaking != "right" ? LEFT : RIGHT;
		}

		intendedanim_left = cur.expressionleft;
		intendedanim_right = cur.expressionright;

		if (cur.forceleft)
			replayAnim(true, true);
		if (cur.forceright)
			replayAnim(false, true);

		allowInput = true;
	}

	var lastLength:Int = 0;
	var charBlacklist:Array<String> = [",", ".", "/", "!", "-", " ", "", "]", "[", "(", ")"];

	public override function update(e:Float)
	{
		super.update(e);

		if (dialogueText.visible)
		{
			dialogueText.x = dialogueBox.x + dialogueSpaceLeft;
			dialogueText.y = dialogueBox.y + dialogueBox.height / 3 + 5;
			dialogueText.fieldWidth = (dialogueBox.width * 0.75) - dialogueSpaceRight;
			// ssssss.volume = 0.35 * FlxG.sound.volume;
		}

		if (leftSprite != null && leftSprite.visible)
		{
			leftSprite.x = dialogueBox.x + 20;
			leftSprite.y = dialogueBox.y + dialogueBox.height - leftSprite.height - 16;
		}
		if (rightSprite != null && rightSprite.visible)
		{
			var wizardOffset:Int = 0;
			if (cur.rightchar == "pngwizard" && cur.expressionright == "png")
				wizardOffset = 365;
			rightSprite.x = dialogueBox.x + dialogueBox.width - rightSprite.width - 20 + wizardOffset;
			rightSprite.y = dialogueBox.y + dialogueBox.height - rightSprite.height - 33;
		}

		if ((FlxG.keys.justPressed.ENTER && allowInput) || (skipWhenDone && !dialogueInProgress))
			nextDialogue();

		checkDialogue();
	}

	public function checkCharacter(name:String, left:Bool)
	{
		if (closing)
			return;

		var nextchar:String = name.toLowerCase().replace(" ", "-");

		if (nextchar == "")
		{
			if (left)
			{
				if (leftSprite != null)
					leftSprite.visible = false;
				lastchar_left_washidden = true;
			}
			else
			{
				if (rightSprite != null)
					rightSprite.visible = false;
				lastchar_right_washidden = true;
			}
		}

		var oldChar:String = left ? lastchar_left : lastchar_right;

		if (oldChar == nextchar || !Assets.exists(Paths.image("dialogue characters/" + name)))
			return;

		if (left)
		{
			if (leftSprite != null)
			{
				remove(leftSprite);
				leftSprite.destroy();
				leftSprite = null;
			}
			lastchar_left_washidden = false;
		}
		else
		{
			if (rightSprite != null)
			{
				remove(rightSprite);
				rightSprite.destroy();
				rightSprite = null;
			}
			lastchar_right_washidden = true;
		}

		var animNames:Array<String> = [];
		var animValues:Array<String> = [];
		var animLooped:Array<Bool> = [];

		var pushAnim:(String, String, Bool) -> Void = function(name:String, value:String, looped:Bool)
		{
			animNames.push(name);
			animValues.push(value);
			animLooped.push(looped);
		};

		switch (name)
		{
			case "jason":
				pushAnim("neutral", "jason - bored0", true);
				pushAnim("confused looking away", "jason - confused looking away0", true);
				pushAnim("confused-speaking", "jason - confused speaking0", false);
				pushAnim("stare", "jason - stare0", true);
				pushAnim("akward-speaking", "jason - akward speaking0", false);
				pushAnim("back-away-1", "jason - back away 10", false);
				pushAnim("back-away-2", "jason - back away 20", false);
				pushAnim("back-away-SPEAK", "jason - back away speak0", false);
				pushAnim("hold-crystal-relief", "jason - holding crystal0", false);
				pushAnim("jpeg-quality", "jason - jpeg0", false);
				pushAnim("DEATHSTARE", "jason - deathstare0", true);
				pushAnim("smirk", "jason - smirk0", false);
				pushAnim("smirk-look", "jason - smirk-look0", false);
				pushAnim("flabbergasted", "jason - flabber gasted0", true);
			case "pngwizard":
				pushAnim("png", "wizard - png0", false);
				pushAnim("deathstare", "wizard - deathstare0", false);
		}

		if (animNames.length == 0 || animNames.length != animValues.length || animNames.length != animLooped.length)
			return;

		if (left)
		{
			intendedanim_left = animNames[0];
			lastchar_left = nextchar;

			leftSprite = new FlxSprite();
			leftSprite.frames = Paths.sparrowv2("dialogue characters/" + name);
			for (i in 0...animNames.length)
				leftSprite.animation.addByPrefix(animNames[i], animValues[i], 24, animLooped[i]);
			add(leftSprite);
			trace("loaded " + name + " on the left");

			replayAnim(true, true);
		}
		else
		{
			intendedanim_right = animNames[0];
			lastchar_right = nextchar;

			rightSprite = new FlxSprite();
			rightSprite.frames = Paths.sparrowv2("dialogue characters/" + name);
			for (i in 0...animNames.length)
			{
				trace(animNames[i] + " " + animValues[i] + " " + (animLooped[i] ? "true" : "false"));
				rightSprite.animation.addByPrefix(animNames[i], animValues[i], 24, animLooped[i]);
			}
			add(rightSprite);

			trace("loaded " + name + " on the right");

			replayAnim(false, true);
		}

		for (i in 0...animNames.length)
		{
			animNames.pop();
			animValues.pop();
			animLooped.pop();
		}

		animNames = null;
		animValues = null;
		animLooped = null;
	}

	function checkDialogue()
	{
		@:privateAccess
		if (dialogueText._length != lastLength)
		{
			if (dialogueText._length > lastLength)
			{
				var newStr:String = dialogueText._finalText.substr(dialogueText._length, dialogueText._length - lastLength);
				lastLength = dialogueText._length;
				if (!charBlacklist.contains(newStr))
					replayAnim(cur.speaking.toLowerCase() == "left");
				return;
			}
			lastLength = dialogueText._length;
			// replayAnim(cur.speaking.toLowerCase() == "left");
			return;
		}
	}

	var intendedanim_left:String = "";
	var intendedanim_right:String = "";

	public function replayAnim(left:Bool, ?forced:Bool = false)
	{
		if (closing)
			return;
		var spr:FlxSprite = left ? leftSprite : rightSprite;
		if (spr == null || spr.animation == null)
			return;
		var a:Bool = spr.animation.curAnim == null;
		if ((!a && (spr.animation.curAnim.looped || !spr.animation.curAnim.finished)) && !forced)
			return;
		spr.animation.play((left ? intendedanim_left : intendedanim_right), true, 0);
	}
}
