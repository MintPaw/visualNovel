package ;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.Assets;
import motion.Actuate;

class Scene extends Sprite
{
	private var _bg:Bitmap;
	private var _oldBg:Bitmap;

	public function new() {
		super();
		_bg = new Bitmap(Assets.getBitmapData("img/noBg.png"));
	}

	public function changeBg(imagePath:String):Void
	{
		_oldBg = _bg;
		_bg = new Bitmap(Assets.getBitmapData(imagePath));
		_bg.alpha = 0;
		addChild(_bg);

		Actuate.tween(_bg, 2, { alpha: 1 }).onComplete(function() {
			removeChild(_oldBg);
			_oldBg = null;
		});

	}

}
