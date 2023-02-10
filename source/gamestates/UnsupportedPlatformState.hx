package gamestates;

#if html5
import flixel.FlxG;
import flixel.text.FlxText;

class UnsupportedPlatformState extends TJState
{
	public var pressedKeys:Bool = false;
	public var platformText:FlxText;

	override public function create()
	{
		super.create();

		platformText = new FlxText(0, 0, 0,
			"Hey!\nWe appreciate the enthusiasm, however, we have bad news.\nThis game may only be played on keyboard & mouse, not touch screen.\nSupport may be added in the future.\n\nSorry!\n-DillyzThe1\n\n(pss! hey! if this is a mistake, then hit any key to continue!)");
		platformText.size = 32;
		platformText.antialiasing = false;
		add(platformText);
		platformText.screenCenter();
	}

	override public function update(e:Float)
	{
		super.update(e);

		if (FlxG.keys.justPressed.ANY && !pressedKeys)
		{
			pressedKeys = true;
			FlxG.sound.play(Paths.sound("clownin around"), 1.15, false, null, true, function()
			{
				FlxG.switchState(new TitleScreenState());
			});
		}
	}

	override function destroy()
	{
		platformText.destroy();
		super.destroy();
	}
}
#end
