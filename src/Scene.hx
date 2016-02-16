package ;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.Assets;
import motion.Actuate;

class Scene extends Sprite
{
	private var _bg:Bitmap;
	private var _oldBg:Bitmap;

	private var _images:Map<String, Bitmap>;

	public function new() {
		super();
		_bg = new Bitmap(Assets.getBitmapData("img/noBg.png"));
		_images = new Map();
	}

	public function changeBg(imagePath:String):Void {
		_oldBg = _bg;
		_bg = new Bitmap(Assets.getBitmapData(imagePath));
		_bg.alpha = 0;
		addChild(_bg);

		Actuate.tween(_bg, 2, { alpha: 1 }).onComplete(function() {
			removeChild(_oldBg);
			_oldBg = null;
		});
	}

	public function addImage(name:String, imgPath:String):Void {
		_images.set(name, new Bitmap(Assets.getBitmapData(imgPath)));
		addChild(_images.get(name));
	}

	public function moveImage(name:String, x:Int, y:Int):Void {
		_images.get(name).x = x;
		_images.get(name).y = y;
	}

	public function removeImage(name:String):Void {
		_images.get(name).x = x;
		_images.get(name).y = y;
		removeChild(_images.get(name));
	}

}
