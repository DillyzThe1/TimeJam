package objects;

import flixel.FlxSprite;
import flixel.math.FlxPoint;

class PNGWizard extends FlxSprite
{
	public var sprSize:FlxPoint = FlxPoint.get(293, 280);

	public var dialogueIndication:FlxSprite;

	public var dialogueEnabled(get, set):Bool;

	private var _dialogueEnabled:Bool = false;

	public function new(midX:Float, groundY:Float)
	{
		super(midX - sprSize.x / 2, groundY - sprSize.y);
		loadGraphic(Paths.image("characters/pngwizard"));

		dialogueIndication = new FlxSprite(midX, groundY - sprSize.y - 20).loadGraphic(Paths.image("dialoguetemp"));
		dialogueIndication.x -= dialogueIndication.width / 2;
		dialogueIndication.y -= dialogueIndication.height;
	}

	var fullThing:Float = 0;

	public override function update(e:Float)
	{
		super.update(e);
		fullThing += e;
		dialogueIndication.offset.y = Math.sin(fullThing * 0.85) * 8.5;
	}

	function get_dialogueEnabled():Bool
	{
		return _dialogueEnabled;
	}

	function set_dialogueEnabled(value:Bool):Bool
	{
		_dialogueEnabled = value;
		dialogueIndication.alpha = _dialogueEnabled ? 0.7 : 0.375;
		return _dialogueEnabled;
	}
}
