package gamestates;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;

using TJUtil;

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
		// TEMPORARY SOLUTION
		camMAIN.follow(targetObject, LOCKON, #if html5 0.05 #else 0.0315 #end / (FlxG.updateFramerate / 60));
		targetPoint = targetObject.getPosition();
		camMAIN.focusOn(targetPoint);

		#if html5
		FlxG.keys.preventDefaultKeys = [];
		#end
	}

	override public function update(e:Float)
	{
		super.update(e);

		var lerp:Float = (e * 114 * (FlxG.updateFramerate / 120)).clampFloat(0.01, 0.99);

		camMAIN.zoom = FlxMath.lerp(zoomMAIN, camMAIN.zoom, lerp);
		camHUD.zoom = FlxMath.lerp(zoomHUD, camHUD.zoom, lerp);
	}
}
