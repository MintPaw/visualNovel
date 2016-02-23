package ;

import openfl.display.*;
import openfl.utils.*;
import openfl.Assets;
import motion.Actuate;
import haxe.*;

class Scene extends Sprite
{
	private var _images:Map<String, Image>;

	public function new() {
		super();

		_images = new Map();

		addImage("_bg", "img/noBg.png");
	}

	public function changeBg(imagePath:String):Void {
		var toRem:Bitmap = _images.get("_bg").bmp;

		addImage("_bg", imagePath);
		_images.get("_bg").bmp.width = stage.stageWidth;
		_images.get("_bg").bmp.height = stage.stageHeight;
		_images.get("_bg").bmp.alpha = 0;

		Actuate.tween(_images.get("_bg").bmp, 2, { alpha: 1 }).onComplete(function() {
			removeChild(toRem);
		});
	}

	public function addImage(name:String, imgPath:String):Void {
		var img:Image = {
			path: imgPath,
			bmp: new Bitmap(Assets.getBitmapData(imgPath))
		};

		_images.set(name, img);
		addChild(img.bmp);
	}

	public function moveImage(name:String, x:Int, y:Int):Void {
		_images.get(name).bmp.x = x;
		_images.get(name).bmp.y = y;
	}

	public function removeImage(name:String):Void {
		removeChild(_images.get(name).bmp);
		_images.remove(name);
	}

	public function data(op:String, loadData:String = null):String
	{
		var bmpFields:Array<String> = ["x", "y", "width", "height"];

		if (op == "save") {
		var saveArray:Array<Array<String>> = [];
			for (k in _images.keys()) {
				var obj:Array<String> = [];
				obj.push(k);
				obj.push(_images.get(k).path);

				for (field in bmpFields) {
					obj.push(Reflect.getProperty(_images.get(k).bmp, field));
				}

				saveArray.push(obj);
			}
			var s = new Serializer();
			s.serialize(saveArray);
			return s.toString();
		}

		if (op == "load") {
			if (loadData == null) return "";

			for (k in _images.keys()) removeImage(k);

			var us = new Unserializer(loadData);
			var loadedArray:Array<Array<String>> = us.unserialize();
			// trace(loadedArray);

			for (currentObj in loadedArray) {
				addImage(currentObj[0], currentObj[1]);
				for (field in bmpFields) {
					var bmp:Bitmap = _images.get(currentObj[0]).bmp;
					var index:Int = bmpFields.indexOf(field);
					var fieldValue:Int = Std.parseInt(currentObj[index+2]);
					// trace("Setting", field, index, fieldValue);
					Reflect.setProperty(bmp, field, fieldValue);
				}
			}
		}

		return "";
	}

}

typedef Image = {
	path:String,
	bmp:Bitmap
}
