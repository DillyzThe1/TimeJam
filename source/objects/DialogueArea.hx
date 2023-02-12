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

	public function new(dialogueName:String)
	{
		super();

		dialogueSfx = new FlxSound().loadEmbedded(Paths.sound("dialogue continue"));

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

		dialogueText = new FlxTypeText(0, 0, 0, "", 16, true);
		dialogueText.borderSize = 2;
		dialogueText.borderColor = FlxColor.BLACK;
		dialogueText.borderStyle = FlxTextBorderStyle.OUTLINE;
		dialogueText.visible = false;

		dialogueData = Json.parse(Assets.getText(Paths.json("dialogue/pngintro")));

		add(bg);
		add(dialogueBox);

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

	public function nextDialogue()
	{
		allowInput = false;

		dialogueSfx.volume = FlxG.sound.volume;
		dialogueSfx.play(true, 0);

		if (dialogueInProgress)
		{
			trace("skip");
			dialogueInProgress = false;
			dialogueText.skip();
			allowInput = true;
			return;
		}

		dialogueIndex++;

		if (dialogueIndex >= dialogueData.dialogue.length)
		{
			dialogueText.visible = false;
			trace("we done");
			if (introTween != null)
			{
				introTween.cancel();
				introTween.destroy();
			}

			introTween = FlxTween.tween(this, {
				"bg.alpha": 0,
				"dialogueBox.y": FlxG.height + dialogueBox.height + 100,
				"dialogueBox.scale.x": 1.3,
				"dialogueBox.scale.y": 1.25
			}, 1.5, {
				ease: FlxEase.cubeInOut,
				onComplete: function(t:FlxTween)
				{
					trace("stage 7 walter");
				}
			});
			return;
		}

		var cur:DialogueInstance = dialogueData.dialogue[dialogueIndex];
		dialogueText.visible = (cur.dialogue != "");
		if (dialogueText.visible)
		{
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
				dialogueText._length = 0;
			}
			else
				dialogueText.resetText(cur.dialogue);
			dialogueText.start(0.15, true, false, [], function()
			{
				trace("typed emoji");
				dialogueInProgress = false;
			});
		}
		else
			trace("bruh");

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
			dialogueText.y = dialogueBox.y + dialogueBox.height / 6;
			dialogueText.fieldWidth = dialogueBox.width * 0.85 - dialogueSpaceLeft - dialogueSpaceRight;
		}

		if (FlxG.keys.justPressed.ENTER && allowInput)
			nextDialogue();
	}
}
