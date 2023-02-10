package gamestates;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

class TJState extends FlxState
{
	public static var stateInstance:TJState;

	private var camMAIN:FlxCamera;
	private var camHUD:FlxCamera;

	public var targetObject:FlxObject;

	public var targetPoint:FlxPoint;

	public var zoomMAIN:Float = 1;
	public var zoomHUD:Float = 1;

	override public function create()
	{
		stateInstance = this;
		super.create();
		camMAIN = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camMAIN);
		FlxG.cameras.add(camHUD, false);
		targetObject = new FlxObject(FlxG.width / 2, FlxG.height / 2, 1, 1);
		camMAIN.follow(targetObject, LOCKON, 0.01 / (60 / FlxG.updateFramerate));
		targetPoint = targetObject.getPosition();
		camMAIN.focusOn(targetPoint);
	}

	override public function update(e:Float)
	{
		super.update(e);

		camMAIN.zoom = FlxMath.lerp(zoomMAIN, camMAIN.zoom, e * 114);
		camHUD.zoom = FlxMath.lerp(zoomHUD, camHUD.zoom, e * 114);
	}
}
