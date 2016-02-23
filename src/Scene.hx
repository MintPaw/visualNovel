package ;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.Assets;
import motion.Actuate;

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

}

typedef Image = {
	path:String,
	bmp:Bitmap
}
