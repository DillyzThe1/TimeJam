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

	var ssssss:FlxSound;

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
		ssssss = new FlxSound().loadEmbedded(Paths.sound("type"));
		dialogueText.sounds = [ssssss];

		dialogueData = Json.parse(Assets.getText(Paths.json("dialogue/pngintro")));
		dialogueSfx = new FlxSound().loadEmbedded(Paths.sound("dialogue continue"));

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
				trace("stage 5 walter");
				nextDialogue();
			}
		});
	}

	var dialogueSpaceLeft:Int = 75;
	var dialogueSpaceRight:Int = 75;
	var dialogueInProgress:Bool = false;

	var allowInput:Bool = false;

	var skipWhenDone:Bool = true;

	public function nextDialogue()
	{
		allowInput = false;

		if (dialogueInProgress)
		{
			trace("skip");
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
			trace("we done");
			if (introTween != null)
			{
				introTween.cancel();
				introTween.destroy();
			}

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

		var cur:DialogueInstance = dialogueData.dialogue[dialogueIndex];
		dialogueText.visible = (cur.dialogue != "");
		if (dialogueText.visible && cur.dialogue != "__continue")
		{
			dialogueInProgress = true;
			trace("do the thing");
			@:privateAccess
			if (!cur.clear)
			{
				trace("...but manually");
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
				trace("typed emoji");
				dialogueInProgress = false;
			});
		}
		else
			trace("bruh");
		skipWhenDone = cur.skip_prompt;
		FlxG.sound.music.volume = 0.2 * cur.music_vol_mult;

		dialogueText.alignment = cur.speaking == "left" ? LEFT : RIGHT;

		dialogueBox.animation.play(cur.boxtype.toLowerCase(), true);
		switch (cur.boxtype.toLowerCase())
		{
			case "none":
				dialogueSpaceLeft = dialogueSpaceRight = 75;
			case "left":
				dialogueSpaceLeft = 275;
				dialogueSpaceRight = 75;
			case "right":
				dialogueSpaceLeft = 75;
				dialogueSpaceRight = 275;
			case "both":
				dialogueSpaceLeft = dialogueSpaceRight = 275;
		}
		allowInput = true;
	}

	public override function update(e:Float)
	{
		super.update(e);

		if (dialogueText.visible)
		{
			dialogueText.x = dialogueBox.x + dialogueSpaceLeft;
			dialogueText.y = dialogueBox.y + dialogueBox.height / 3;
			dialogueText.fieldWidth = (dialogueBox.width * 0.75) - dialogueSpaceRight;
			ssssss.volume = 0.35 * FlxG.sound.volume;
		}

		if ((FlxG.keys.justPressed.ENTER && allowInput) || (skipWhenDone && !dialogueInProgress))
			nextDialogue();
	}
}
