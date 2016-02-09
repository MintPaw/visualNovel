package ;

import openfl.display.Sprite;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.geom.Rectangle;
import openfl.text.TextField;
import openfl.text.TextFieldAutoSize;
import openfl.text.TextFormat;
import openfl.events.Event;
import openfl.events.KeyboardEvent;
import openfl.events.MouseEvent;
import openfl.ui.Keyboard;
import openfl.Assets;
import motion.Actuate;

@:publicFields
class F_Button
{
	public static function test():Void
	{
		trace(test);
	}

	static function makeButton(up:String, over:String, down:String):Button {
		// I need the size
		var up:BitmapData = Assets.getBitmapData(up);

		var b:Button = {
			bitmap: new Bitmap(new BitmapData(up.width, up.height)),
			state: 0,
			up: up,
			over: Assets.getBitmapData(over),
			down: Assets.getBitmapData(down)
		};

		b.bitmap.bitmapData.draw(b.up);

		return b;
	}
}

typedef Button =
{
	?bitmap:Bitmap,
	?state:Int,
	?onClick:Void -> Void,
	?up:BitmapData,
	?over:BitmapData,
	?down:BitmapData
}
