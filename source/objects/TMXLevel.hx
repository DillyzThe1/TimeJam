package objects;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.editors.tiled.TiledImageLayer;
import flixel.addons.editors.tiled.TiledImageTile;
import flixel.addons.editors.tiled.TiledLayer.TiledLayerType;
import flixel.addons.editors.tiled.TiledLayer;
import flixel.addons.editors.tiled.TiledMap;
import flixel.addons.editors.tiled.TiledObject;
import flixel.addons.editors.tiled.TiledObjectLayer;
import flixel.addons.editors.tiled.TiledTileLayer;
import flixel.addons.editors.tiled.TiledTilePropertySet;
import flixel.addons.editors.tiled.TiledTileSet;
import flixel.addons.tile.FlxTileSpecial;
import flixel.addons.tile.FlxTilemapExt;
import flixel.group.FlxGroup;
import flixel.math.FlxPoint;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.util.FlxDirectionFlags;
import gamestates.PlayState;
import managers.PlayerPreferenceManager;
import objects.ArcahicCrystal.ArchaicCrystal;

using StringTools; // based on https://github.com/HaxeFlixel/flixel-demos/blob/dev/Editors/TiledEditor/source/TiledLevel.hx

class TMXLevel extends TiledMap
{
	public var bgGroup:FlxGroup;
	public var sprGroup:FlxGroup;
	public var objGroup:FlxGroup;
	public var fgGroup:FlxGroup;

	var semiSolids:Array<FlxTilemap>;
	var collisionTiles:Array<FlxTilemap>;

	public var playerStart:FlxPoint = FlxPoint.get();

	public var wizard:PNGWizard;
	public var timelineReflector:TimelineReflector;

	public function new(tilelevel:FlxTiledMapAsset)
	{
		super(tilelevel);

		FlxG.worldBounds.set(0, 0, 100, 100);

		bgGroup = new FlxGroup();
		sprGroup = new FlxGroup();
		objGroup = new FlxGroup();
		fgGroup = new FlxGroup();

		collisionTiles = new Array<FlxTilemap>();
		semiSolids = new Array<FlxTilemap>();

		initiateGraphics();
		initiateAllObjects();
		loadTiles();

		for (layer in layers)
		{
			if (layer.type != TiledLayerType.TILE)
				continue;

			if (isLayerDisabled(layer))
				continue;

			var tileLayer:TiledTileLayer = cast layer;

			for (set in tilesets)
			{
				if (tileLayer.offsetX < FlxG.worldBounds.x)
					FlxG.worldBounds.x = tileLayer.offsetX;
				if (tileLayer.offsetY < FlxG.worldBounds.y)
					FlxG.worldBounds.y = tileLayer.offsetY;
				if (tileLayer.width * set.tileWidth > FlxG.worldBounds.width)
					FlxG.worldBounds.width = tileLayer.width * set.tileWidth;
				if (tileLayer.height * set.tileHeight > FlxG.worldBounds.height)
					FlxG.worldBounds.height = tileLayer.height * set.tileHeight;
			}
		}

		trace('[${FlxG.worldBounds.x}, ${FlxG.worldBounds.y}, ${FlxG.worldBounds.width}, ${FlxG.worldBounds.height}]');
	}

	function isLayerDisabled(curLayer:TiledLayer)
	{
		var tryproperty:String = curLayer.properties.get("spawn_whenhas");
		var spawnwhen:Int = (tryproperty == null) ? -1 : Std.parseInt(tryproperty);
		if (spawnwhen != -1 && !ArchaicCrystal.crystalsCollected.contains(spawnwhen))
			return true;
		tryproperty = curLayer.properties.get("despawn_whenhas");
		var despawnwhen:Int = (tryproperty == null) ? -1 : Std.parseInt(tryproperty);
		if (despawnwhen != -1 && ArchaicCrystal.crystalsCollected.contains(despawnwhen))
			return true;
		return curLayer.properties.get("disabled") == "true";
	}

	function initiateGraphics()
	{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.IMAGE)
				continue;

			if (isLayerDisabled(layer))
				continue;

			var imgLayer:TiledImageLayer = cast layer;
			sprGroup.add(new FlxSprite(imgLayer.x, imgLayer.y, Paths.imagetmx(imgLayer.imagePath)));
		}
	}

	function initiateAllObjects()
	{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.OBJECT)
				continue;

			if (isLayerDisabled(layer))
				continue;

			var objLayer:TiledObjectLayer = cast layer;

			if (objLayer.name == "images")
				for (o in objLayer.objects)
					loadIndividualGraphicalObject(o);
			else if (objLayer.name.startsWith("objects"))
				for (o in objLayer.objects)
					loadIndividualObject(o, objLayer);
		}
	}

	function loadIndividualGraphicalObject(obj:TiledObject)
	{
		var imgCollection:TiledTileSet = getTileSet("imageCollection");
		var imgSource:TiledImageTile = imgCollection.getImageSourceByGid(obj.gid);
		var spr:FlxSprite = new FlxSprite().loadGraphic(Paths.imagetmx(imgSource.source));

		if (spr.width != obj.width || spr.height != obj.height)
			spr.setGraphicSize(obj.width, obj.height);

		spr.flipX = obj.flippedHorizontally;
		spr.flipY = obj.flippedVertically;
		spr.setPosition(obj.x, obj.y - spr.height);
		spr.origin.set(0, spr.height);
		spr.angle = obj.angle;

		if (obj.properties.contains("depth"))
		{
			var depth:Float = Std.parseFloat(obj.properties.get("depth"));
			spr.scrollFactor.set(depth, depth);
		}

		bgGroup.add(spr);
	}

	function loadIndividualObject(obj:TiledObject, objLayer:TiledObjectLayer)
	{
		var pos:FlxPoint = FlxPoint.get(obj.x, obj.y);

		if (obj.gid != -1)
			pos.y -= objLayer.map.getGidOwner(obj.gid).tileHeight;

		var summonName:String = obj.properties.get("summon");

		switch (summonName)
		{
			case "player_start":
				playerStart.set(pos.x, pos.y);
			case "crystal":
				var crystalIndex = Std.parseInt(obj.properties.get("crystal_index"));
				if (!ArchaicCrystal.crystalsCollected.contains(crystalIndex))
				{
					var crystal:ArchaicCrystal = new ArchaicCrystal(pos.x + obj.width / 2, pos.y + obj.height / 2, crystalIndex);
					objGroup.add(crystal);
				}
			case "pngwizard":
				if (wizard != null)
				{
					trace('Warning! Too many wizards have been attempted to have been indexed!');
					return;
				}

				wizard = new PNGWizard(obj.x + obj.width / 2, obj.y + obj.height);
				// objGroup.add(wizard.dialogueIndication);
				objGroup.add(wizard);
			case "timeline-reflector":
				timelineReflector = new TimelineReflector(obj.x + obj.width / 2, obj.y + obj.height);
				objGroup.add(timelineReflector);
			default:
				trace('Warning! Object summon "$summonName" unaccounted for! (On object "${obj.name}")');
		}

		pos.put();
	}

	function loadTiles()
	{
		for (layer in layers)
		{
			if (layer.type != TiledLayerType.TILE)
				continue;

			if (isLayerDisabled(layer))
				continue;

			var tileLayer:TiledTileLayer = cast layer;
			var tileSetName:String = tileLayer.properties.get("tileset");

			if (tileSetName == null)
			{
				trace('Variable "tileset" is undefined for layer "${tileLayer.name}"!');
				continue;
			}

			var tileSet:TiledTileSet = null;
			for (set in tilesets)
			{
				if (set.name == tileSetName)
				{
					tileSet = set;
					break;
				}
			}

			if (tileSet == null)
			{
				trace('Tileset "${tileSetName}" is unavailable!');
				continue;
			}

			var tilemap:FlxTilemapExt = new FlxTilemapExt();
			tilemap.loadMapFromArray(tileLayer.tileArray, width, height, Paths.imagetmx(tileSet.imageSource), tileSet.tileWidth, tileSet.tileHeight,
				FlxTilemapAutoTiling.OFF, tileSet.firstGID, 1, 1);
			tilemap.antialiasing = PlayerPreferenceManager.antialiasing;

			var leftdis:Bool = tileLayer.properties.get("leftDisabled") == "true";
			var rightdis:Bool = tileLayer.properties.get("rightDisabled") == "true";
			var updis:Bool = tileLayer.properties.get("upDisabled") == "true";
			var downdis:Bool = tileLayer.properties.get("downDisabled") == "true";

			if (leftdis && rightdis && !updis && downdis)
				semiSolids.push(tilemap);

			tilemap.allowCollisions = FlxDirectionFlags.fromBools(!leftdis, !rightdis, !updis, !downdis);

			if (tileLayer.properties.contains("animated"))
			{
				var curSet:TiledTileSet = tilesets["level"];
				var uniqueTiles:Map<Int, TiledTilePropertySet> = new Map<Int, TiledTilePropertySet>();

				for (prop in curSet.tileProps)
					if (prop != null && prop.animationFrames.length > 0)
						uniqueTiles[prop.tileID + curSet.firstGID] = prop;

				var uniqueTileOutput:Array<FlxTileSpecial> = new Array<FlxTileSpecial>();
				for (tile in tileLayer.tiles)
					uniqueTileOutput.push((tile != null && uniqueTiles.exists(tile.tileID)) ? getAnimatedTile(uniqueTiles[tile.tileID], curSet) : null);
				tilemap.setSpecialTiles(uniqueTileOutput);
			}

			if (tileLayer.properties.contains("nocollide"))
				bgGroup.add(tilemap);
			else
			{
				trace("adding " + tileLayer.name + " to the collision");
				fgGroup.add(tilemap);
				collisionTiles.push(tilemap);
			}
		}
	}

	function getAnimatedTile(props:TiledTilePropertySet, set:TiledTileSet)
	{
		var tile:FlxTileSpecial = new FlxTileSpecial(1, false, false, 0);
		var offset:Int = Std.random(props.animationFrames.length);
		var frames:Array<Int> = new Array<Int>();
		for (i in 0...props.animationFrames.length)
			frames.push(props.animationFrames[(i + offset) % props.animationFrames.length].tileID + set.firstGID);
		tile.addAnimation(frames, 1000 / props.animationFrames[0].duration);
		return tile;
	}

	public function checkCollision(target:FlxObject, ?notifyCallback:FlxObject->FlxObject->Void, ?processCallback:FlxObject->FlxObject->Bool)
	{
		for (map in collisionTiles)
			if (FlxG.overlap(map, target, notifyCallback, processCallback != null ? processCallback : FlxObject.separate))
				return true;
		return false;
	}

	public var lastWasSemi:Bool = false;

	public function checkCollisionAlt(target:FlxObject, ?ignoreSemis:Bool = false)
	{
		for (map in collisionTiles)
		{
			if (ignoreSemis && semiSolids.contains(map))
				continue;
			if (FlxG.collide(map, target))
			{
				lastWasSemi = semiSolids.contains(map);
				return true;
			}
		}
		lastWasSemi = false;
		return false;
	}
}
