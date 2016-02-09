package ;

import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.Assets;
import openfl.geom.Rectangle;

class Button extends Bitmap
{
	public var state:Int;
	public var onClick:Void -> Void;

	public var up:BitmapData;
	public var over:BitmapData;
	public var down:BitmapData;

	public function new(upPath:String, overPath:String, downPath:String) {
		// I need the size
		up = Assets.getBitmapData(upPath);
		super(new BitmapData(up.width, up.height));

		state = 0;
		over = Assets.getBitmapData(overPath);
		down = Assets.getBitmapData(downPath);

		bitmapData.draw(up);
	}

	public function update() {
		if (stage == null) return;
		trace(onClick);

		var mouseX:Int = Std.int(stage.mouseX);
		var mouseY:Int = Std.int(stage.mouseY);

		var bRect:Rectangle = bitmapData.rect.clone();
		bRect.offset(x, y);

		if (bRect.contains(mouseX, mouseY)) {
			trace("hover");

			if (Story.mouseDown && state != 2) {
				bitmapData.draw(down);
				state = 2;
			} else if (!Story.mouseDown && state != 1) {
				if (state == 2) onClick();
				bitmapData.draw(over);
				state = 1;
			}

		} else if (state != 0) {
			bitmapData.draw(up);
			state = 0;
		}
	}
}
