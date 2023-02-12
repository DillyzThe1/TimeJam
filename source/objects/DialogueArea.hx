package objects;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
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

	public var introTween:FlxTween;

	public function new(dialogueName:String)
	{
		super();

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
			}
		});
	}
}
